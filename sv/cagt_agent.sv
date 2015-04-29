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
 * MODULE:      cagt_agent.sv
 * PROJECT:     Common Agent
 * Description: This file contains the declaration of the agent class.
 *******************************************************************************/

`ifndef CAGT_AGENT_SV
	//protection against multiple includes
	`define CAGT_AGENT_SV

	//agent class
	class cagt_agent #(type VIRTUAL_INTF_TYPE=int, type MONITOR_ITEM=uvm_object, type DRIVER_ITEM_REQ=uvm_sequence_item, type DRIVER_ITEM_RSP=DRIVER_ITEM_REQ) extends uvm_agent;

		//agent configuration
		cagt_agent_config#(VIRTUAL_INTF_TYPE) agent_config;

		//monitor
		cagt_monitor#(VIRTUAL_INTF_TYPE, MONITOR_ITEM) monitor;

		//coverage
		cagt_coverage#(VIRTUAL_INTF_TYPE, MONITOR_ITEM) coverage;

		//driver
		cagt_driver #(VIRTUAL_INTF_TYPE, DRIVER_ITEM_REQ, DRIVER_ITEM_RSP) driver;

		//sequencer
		cagt_sequencer #(DRIVER_ITEM_REQ, DRIVER_ITEM_RSP) sequencer;

		`uvm_component_param_utils(cagt_agent#(VIRTUAL_INTF_TYPE, MONITOR_ITEM, DRIVER_ITEM_REQ, DRIVER_ITEM_RSP))

		//constructor
		//@param name - name of the component instance
		//@param parent - parent of the component instance
		function new(string name, uvm_component parent);
			super.new(name, parent);
		endfunction

		//function for getting the ID used in messaging
		//@return message ID
		virtual function string get_id();
			return "AGT";
		endfunction

		//UVM build phase
		//@param phase - current phase
		virtual function void build_phase(uvm_phase phase);
			super.build_phase(phase);

			if(!uvm_config_db#(cagt_agent_config#(VIRTUAL_INTF_TYPE))::get(this, "", "agent_config", agent_config)) begin
				`uvm_fatal(get_id(), $sformatf("Agent configuration class was not set in database for agent %s", get_full_name()));
			end

			monitor = cagt_monitor#(VIRTUAL_INTF_TYPE, MONITOR_ITEM)::type_id::create("monitor", this);

			is_active = agent_config.get_is_active();

			if(is_active == UVM_ACTIVE) begin
				driver = cagt_driver#(VIRTUAL_INTF_TYPE, DRIVER_ITEM_REQ, DRIVER_ITEM_RSP)::type_id::create("driver", this);
				sequencer = cagt_sequencer#(DRIVER_ITEM_REQ, DRIVER_ITEM_RSP)::type_id::create("sequencer", this);
			end

			if(agent_config.get_has_coverage() == 1) begin
				coverage = cagt_coverage#(VIRTUAL_INTF_TYPE, MONITOR_ITEM)::type_id::create("coverage", this);
			end
		endfunction

		//UVM connect phase
		//@param phase - current phase
		virtual function void connect_phase(uvm_phase phase);
			super.connect_phase(phase);

			monitor.agent_config = agent_config;

			if(driver != null) begin
				driver.agent_config = agent_config;
			end

			if(coverage != null) begin
				coverage.agent_config = agent_config;
				monitor.output_port.connect(coverage.item_from_mon_port);
			end

			if((driver != null) && (sequencer != null)) begin
				driver.seq_item_port.connect(sequencer.seq_item_export);
			end
		endfunction

		//task for waiting the reset to start
		virtual task wait_reset_start();
			agent_config.wait_reset_start();
		endtask

		//task for waiting the reset to be finished
		virtual task wait_reset_end();
			agent_config.wait_reset_end();
		endtask

		//function for handling reset
		virtual function void handle_reset(uvm_phase phase);
			monitor.handle_reset();

			if(driver != null) begin
				driver.handle_reset();
			end

			if(sequencer != null) begin
				sequencer.handle_reset(phase);
			end

			if(coverage != null) begin
				coverage.handle_reset();
			end
		endfunction

		//UVM run phase
		//@param phase - current phase
		virtual task run_phase(uvm_phase phase);
			forever begin
				wait_reset_start();
				`uvm_info(get_id(), "Reset start detected", UVM_LOW)
				handle_reset(phase);
				wait_reset_end();
				`uvm_info(get_id(), "Reset end detected", UVM_LOW)
			end
		endtask

	endclass

`endif

