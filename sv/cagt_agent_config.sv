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
 * MODULE:      cagt_agent_config.sv
 * PROJECT:     Common Agent
 * Description: This file contains the declaration of the agent configuration class.
 *******************************************************************************/

`ifndef CAGT_AGENT_CONFIG_SV
	//protection against multiple includes
	`define CAGT_AGENT_CONFIG_SV

	//agent configuration class
	class cagt_agent_config #(type VIRTUAL_INTF_TYPE=int) extends uvm_component;

		//switch to determine the active or the passive aspect of the agent
		protected uvm_active_passive_enum is_active = UVM_ACTIVE;

		//switch to determine if to enable or not the coverage
		protected bit has_coverage = 1;

		//switch to determine if to enable or not the checks
		protected bit has_checks = 1;

		//active level of reset signal
		protected bit reset_active_level = 0;

		//pointer to the DUT interface
		protected VIRTUAL_INTF_TYPE dut_vif;

		//function for getting the value of is_active field
		//@return is_active field value
		virtual function uvm_active_passive_enum get_is_active();
			return is_active;
		endfunction

		//function for setting a new value for is_active field
		//@param is_active - new value of the is_active field
		virtual function void set_is_active(uvm_active_passive_enum is_active);
			this.is_active = is_active;
		endfunction

		//function for getting the value of has_coverage field
		//@return has_coverage field value
		virtual function bit get_has_coverage();
			return has_coverage;
		endfunction

		//function for setting a new value for has_coverage field
		//@param has_coverage - new value of the has_coverage field
		virtual function void set_has_coverage(bit has_coverage);
			this.has_coverage = has_coverage;
		endfunction

		//function for getting the value of has_checks field
		//@return has_checks field value
		virtual function bit get_has_checks();
			return has_checks;
		endfunction

		//function for setting a new value for has_checks field
		//@param has_checks - new value of the has_checks field
		virtual function void set_has_checks(bit has_checks);
			this.has_checks = has_checks;
		endfunction

		//function for getting the value of dut_vif field
		//@return dut_vif field value
		virtual function VIRTUAL_INTF_TYPE get_dut_vif();
			return dut_vif;
		endfunction

		//function for setting a new value for dut_vif field
		//@param dut_vif - new value of the dut_vif field
		virtual function void set_dut_vif(VIRTUAL_INTF_TYPE dut_vif);
			this.dut_vif = dut_vif;
		endfunction

		//function for getting the value of reset_active_level field
		//@return reset_active_level field value
		virtual function bit get_reset_active_level();
			return reset_active_level;
		endfunction

		//function for setting a new value for reset_active_level field
		//@param reset_active_level - new value of the reset_active_level field
		virtual function void set_reset_active_level(bit reset_active_level);
			this.reset_active_level = reset_active_level;
		endfunction

		`uvm_component_param_utils(cagt_agent_config#(VIRTUAL_INTF_TYPE))

		//function for getting the ID used in messaging
		//@return message ID
		virtual function string get_id();
			return "AGT_CFG";
		endfunction

		//constructor
		//@param name - name of the component instance
		//@param parent - parent of the component instance
		function new(string name, uvm_component parent);
			super.new(name, parent);
		endfunction

		//UVM start of simulation phase
		//@param phase - current phase
		virtual function void start_of_simulation_phase(input uvm_phase phase);
			super.start_of_simulation_phase(phase);

			assert (dut_vif != null) else
				`uvm_fatal(get_id(), "The pointer to the DUT interface is null - please make sure you set it via set_dut_vif() function before \"Start of Simulation\" phase!");
		endfunction

		//task for waiting the reset to start
		virtual task wait_reset_start();
			`uvm_fatal(get_id(), $sformatf("You must implement wait_reset_start() task from %s(%s)", get_full_name(), get_type_name()))
		endtask

		//task for waiting the reset to be finished
		virtual task wait_reset_end();
			`uvm_fatal(get_id(), $sformatf("You must implement wait_reset_end() task from %s(%s)", get_full_name(), get_type_name()))
		endtask

	endclass

`endif
