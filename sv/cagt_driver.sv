/******************************************************************************
 * (C) Copyright 2014 AMIQ Consulting
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * MODULE:      cagt_driver.sv
 * PROJECT:     Common Agent
 * Engineer(s): Cristian Florin Slav (cristian.slav@amiq.com)
 *
 * Description: This file contains the declaration of the monitor class.
 *******************************************************************************/

`ifndef CAGT_DRIVER_SV
	//protection against multiple includes
	`define CAGT_DRIVER_SV

	//driver class
	class cagt_driver #(type VIRTUAL_INTF_TYPE=int, type REQ=uvm_sequence_item, type RSP=REQ) extends uvm_driver#(.REQ(REQ), .RSP(RSP));

		//pointer to the agent configuration class
		cagt_agent_config #(VIRTUAL_INTF_TYPE) agent_config;

		//port for sending the item to be driven on bus
		uvm_analysis_port#(REQ) output_port;

		//process for drive_transactions() task
		protected process process_drive_transactions;

		`uvm_component_param_utils(cagt_driver#(VIRTUAL_INTF_TYPE, REQ, RSP))

		//constructor
		//@param name - name of the component instance
		//@param parent - parent of the component instance
		function new(string name, uvm_component parent);
			super.new(name, parent);
			output_port = new("output_port", this);
		endfunction

		//function for getting the ID used in messaging
		//@return message ID
		virtual function string get_id();
			return "DRV";
		endfunction

		//task for waiting the reset to be finished
		virtual task wait_reset_end();
			agent_config.wait_reset_end();
		endtask

		//function for handling reset
		virtual function void handle_reset();
			if(process_drive_transactions != null) begin
				process_drive_transactions.kill();
				`uvm_info(get_id(), "killing process for drive_transactions() task...", UVM_MEDIUM);
			end
		endfunction

		//task for driving one transaction
		virtual task drive_transaction(REQ transaction);
			`uvm_fatal(get_id(), $sformatf("You must implement drive_transaction() task from %s(%s)", get_full_name(), get_type_name()))
		endtask

		//task for driving all transactions
		virtual task drive_transactions();
			fork
				begin
					process_drive_transactions = process::self();
					`uvm_info(get_id(), "Starting drive_transactions()...", UVM_LOW);

					forever begin
						REQ transaction;

						seq_item_port.get_next_item(transaction);
						output_port.write(transaction);

						drive_transaction(transaction);

						seq_item_port.item_done();
					end
				end
			join
		endtask

		//UVM start of simulation phase
		//@param phase - current phase
		virtual function void start_of_simulation_phase(input uvm_phase phase);
			super.start_of_simulation_phase(phase);

			assert (agent_config != null) else
				`uvm_fatal(get_id(), "The pointer to the agent configuration is null - please make sure you set agent_config before \"Start of Simulation\" phase!");
		endfunction

		//UVM run phase
		//@param phase - current phase
		task run_phase(uvm_phase phase);
			forever begin
				fork
					begin
						wait_reset_end();
						drive_transactions();
						disable fork;
					end
				join
			end
		endtask

	endclass
`endif
