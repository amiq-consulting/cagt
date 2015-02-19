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
 * MODULE:      cagt_coverage.sv
 * PROJECT:     Common Agent
 * Engineer(s): Cristian Florin Slav (cristian.slav@amiq.com)
 *
 * Description: This file contains the declaration of the coverage class.
 *******************************************************************************/

`ifndef CAGT_COVERAGE_SV
	//protection against multiple includes
	`define CAGT_COVERAGE_SV

	`uvm_analysis_imp_decl(_item_from_mon)

	//coverage class
	class cagt_coverage#(type VIRTUAL_INTF_TYPE=int, type MONITOR_ITEM=uvm_sequence_item) extends uvm_component;

		//pointer to the agent configuration class
		cagt_agent_config #(VIRTUAL_INTF_TYPE) agent_config;

		//port for receiving items collected by the monitor
		uvm_analysis_imp_item_from_mon#(MONITOR_ITEM, cagt_coverage#(VIRTUAL_INTF_TYPE, MONITOR_ITEM)) item_from_mon_port;

		`uvm_component_param_utils(cagt_coverage#(VIRTUAL_INTF_TYPE, MONITOR_ITEM))

		//constructor
		//@param name - name of the component instance
		//@param parent - parent of the component instance
		function new(string name, uvm_component parent);
			super.new(name, parent);
			item_from_mon_port = new("item_from_mon_port", this);
		endfunction

		//function for getting the ID used in messaging
		//@return message ID
		virtual function string get_id();
			return "COV";
		endfunction

		//implementation of the port receiving item from the monitor
		//@param item - received item from the monitor
		virtual function void write_item_from_mon(input MONITOR_ITEM transfer);

		endfunction

		//function for handling reset
		virtual function void handle_reset();

		endfunction

	endclass
`endif

