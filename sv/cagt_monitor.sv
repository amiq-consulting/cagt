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
 * MODULE:      cagt_monitor.sv
 * PROJECT:     Common Agent
 * Engineer(s): Cristian Florin Slav (cristian.slav@amiq.com)
 *
 * Description: This file contains the declaration of the monitor class.
 *******************************************************************************/

`ifndef CAGT_MONITOR_SV
	//protection against multiple includes
	`define CAGT_MONITOR_SV

	//monitor class
	class cagt_monitor#(type VIRTUAL_INTF_TYPE=int, type MONITOR_ITEM=uvm_object) extends uvm_monitor;

		//pointer to the agent configuration class
		cagt_agent_config #(VIRTUAL_INTF_TYPE) agent_config;

		//process for collect_transactions() task
		protected process process_collect_transactions;

		`uvm_component_param_utils(cagt_monitor#(VIRTUAL_INTF_TYPE, MONITOR_ITEM))

		//port for sending the collected item
		uvm_analysis_port#(MONITOR_ITEM) output_port;

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
			return "MON";
		endfunction

		//task for waiting the reset to be finished
		virtual task wait_reset_end();
			agent_config.wait_reset_end();
		endtask

		//task for collecting one transaction
		virtual task collect_transaction();
			`uvm_fatal(get_id(), $sformatf("You must implement collect_transaction() task from %s(%s)", get_full_name(), get_type_name()))
		endtask

		//task for collecting all transactions
		virtual task collect_transactions();
			fork
				begin
					process_collect_transactions = process::self();

					`uvm_info(get_id(), "Starting collect_transactions()...", UVM_LOW);

					forever begin
						collect_transaction();
					end
				end
			join
		endtask

		//function for handling reset
		virtual function void handle_reset();
			if(process_collect_transactions != null) begin
				process_collect_transactions.kill();
				`uvm_info(get_id(), "killing process for collect_transactions() task...", UVM_MEDIUM);
			end
		endfunction

		//UVM start of simulation phase
		//@param phase - current phase
		virtual function void start_of_simulation_phase(input uvm_phase phase);
			super.start_of_simulation_phase(phase);

			assert (agent_config != null) else
				`uvm_fatal(get_id(), "The pointer to the agent configuration is null - please make sure you set agent_config before \"Start of Simulation\" phase!");
		endfunction

		//UVM run phase
		//@param phase - current phase
		virtual task run_phase(uvm_phase phase);
			forever begin
				fork
					begin
						wait_reset_end();
						collect_transactions();
						disable fork;
					end
				join
			end
		endtask

	endclass
`endif

