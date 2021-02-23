class ApplicationController < ActionController::Base
  before_action :authorize, :page_initializer

  # The expiration time.
  MAX_SESSION_TIME = 60 * 60


  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery  :secret => 'aa1cfae3452a164f9ed2634d319a8631'


  def page_initializer
    @current_subdomain = request.subdomains.first
    @detail2_div = session[:detail2_div]

    @attestation_clinic_filter_controllers = ['home', 'financial_management', 'report', 'batch_attestation']
    @attestation_clinic_filter_controller_actions = ['mass_maintenance-index', 'mass_maintenance-view_attest_ep',
                                                     'mass_maintenance-quick_entry', 'mass_maintenance-add_attestation_history',
                                                     'aci-index', 'aci-aci_summary_report', 'aci-aci_detail_report', 'aci-aci_individual_detail_report',
                                                     'aci-aco_11_detail_report', 'aci-aco_11_individual_detail_report', 'quality-index','quality-cqm_summary_report',
                                                     'quality-cqm_detail_report', 'quality-cqm_selector', 'quality-ec_comparison_tool', 'quality-cqm_date_range_report',
                                                     'cpia-index', 'cpia-physician_assign', 'cpia-cpia_group_summary']

    @current_time = Time.zone.now #user_time_zone_now #Time.zone.now

    # NORMAL MAIN TABS

    # Only C3 master admins see these tabs
    @global_cqm_template_tab = 'Global CQM Templates'
    @global_cqm_template_label = @global_cqm_template_tab

    @attestation_method_tab = 'Entity Types'
    @attestation_method_label = @attestation_method_tab

    @upload_tab = 'Uploads'
    @upload_label = @upload_tab

    @batch_history_tab = 'Batch Histories'
    @batch_history_label = @batch_history_tab

    @splash_page_tab = 'Splash Pages'
    @splash_page_label = @splash_page_tab

    # Only hospitals and physician groups see this tab
    if @selected_mum_program_view == 1 # MUM
      @home_tab = 'Home'
      @data_label = @home_tab
    elsif @selected_mum_program_view == 2 # MIPS
      @home_tab = 'Financial'
      @data_label = @home_tab
    end

    # Everyone sees these tabs
    @compliance_event_tab = "Requirement Set" # replaced on 1/14/2013"Compliance Events"
    @compliance_event_label = @compliance_event_tab

    if @selected_group.group_type_id == 1 or @selected_group.group_type_id == 4
      @requirement_tab = "Requirements"
      @requirement_label = "Requirements View"
    else
      @requirement_tab = "New & Updated Requirements"
      @requirement_label = "New & Updated Requirements View"
    end

    # Only hospitals and physician groups see these tabs
    if @selected_mum_program_view == 1 # MUM
      @group_requirement_tab = 'Requirements'
      @group_requirement_label = 'Requirements View'
    elsif @selected_mum_program_view == 2 # MIPS
      @group_requirement_tab = 'Manage Existing Requirements'
      @group_requirement_label = 'Requirements View'
    end

    @department_management_console_label = "Management Console"
    @department_management_console_tab = @department_management_console_label


    @plan_manager_console_tab = "Action Items"
    @plan_manager_console_label = @plan_manager_console_tab
    @has_active_action_items = ActionItem.any_incomplete_by_group_id?(@selected_group_id)

    @financial_management_tab = "Financials"
    @financial_management_label = @financial_management_tab

    @quick_data_entry_tab = "Quick Entry"
    @quick_data_entry_label = @quick_data_entry_tab
    @mass_data_entry_tab = "Mass Update"
    @mass_data_entry_label = @mass_data_entry_tab
    @add_attestation_history_tab = "Mass Add Attestation History"
    @add_attestation_history_label = @add_attestation_history_tab
    @attest_ep_tab = "Attest An EP"
    @attest_ep_label = @attest_ep_tab
    @mass_actions_tab = "Mass Actions"
    @mass_actions_label = @mass_actions_tab
    @pecos_reconciliation_tab = "PECOS Reconciliation"
    @pecos_reconciliation_label = @pecos_reconciliation_tab
    @tin_quick_data_entry_tab = "TIN Quick Entry"
    @tin_quick_data_entry_label = @tin_quick_data_entry_tab
    @interfaces_tab = "Interfaces"
    @interfaces_label = @interfaces_tab
    @batch_attestation_tab = "Attestation Batch Listing"
    @batch_attestation_label = @batch_attestation_tab
    @group_attestation_requirement_template_tab = "Attestation Requirement Templates"
    @group_attestation_requirement_template_label = @group_attestation_requirement_template_tab

    @attestation_clinic_tab = "Attestation Clinics"
    @attestation_clinic_label = @attestation_clinic_tab

    @clinic_tab = "Internal Clinics"
    @clinic_label = @clinic_tab

    @pecos_clinic_tab = "PECOS Clinics"
    @pecos_clinic_label = @pecos_clinic_tab

    # REPORTS TABS
    @reports_tab = "Reports"
    @reports_label = @reports_tab

    #DISCUSSION BOARD TABS
    @discussion_board_tab = "Community of Practice"
    @discussion_board_label = @discussion_board_tab

    # ADMIN TABS
    @health_system_tab = "Health Systems"
    @health_system_label = @health_system_tab

    if @selected_group.group_type_id == 1 or @selected_group.group_type_id == 4
      @group_tab = "Groups"
    elsif @selected_group.group_type_id == 2
      @group_tab = "Hospitals"
    elsif @selected_group.group_type_id == 3
      @group_tab = "Ambulatory"
    end
    @group_label = @group_tab

    @user_tab = "Users"
    @user_label = @user_tab

    if @selected_group.group_type_id == 1 or @selected_group.group_type_id == 4
      @department_tab = "Level 3"
    elsif @selected_group.group_type_id == 2
      @department_tab = "Departments"
    elsif @selected_group.group_type_id == 3
      @department_tab = "Physicians"
    end
    @department_label = @department_tab

    @ep_type_tab = "EP Types"
    @ep_type_label = "Eligible Professional Types"

    @specialty_tab = "Specialties"
    @specialty_label = @specialty_tab

    @meeting_status_tab = "Meeting Statuses"
    @meeting_status_label = @meeting_status_tab

    @group_actual_payment_tab = "Payments"
    @group_actual_payment_label = @group_actual_payment_tab

    @group_user_defined_values_tab = "User Defined Values"
    @group_user_defined_values_label = @group_user_defined_values_tab

    @criterion_tab = "Category"
    @criterion_label = @criterion_tab

    @sub_criterion_tab = "Sub Category"
    @sub_criterion_label = @sub_criterion_tab

    @technology_tab = "Technology"
    @technology_vendor_label = "Technology Vendors"
    @technology_product_label = "Technology Products"
    @technology_module_label = "Technology Modules"

    @messaging_label = @messaging_tab = "Messaging"

    @cms_update_label = @cms_update_tab = "CMS Update"

    @public_files_label = @public_files_tab = "Public Files"

    # UPPER NAVIGATION LINKS
    @help_tab = "MACRA Guru"
    @about_tab = "About"
    @normal_tab = "Normal"
    @admin_tab = "Admin"
    @edit_tab = "Data"
    @log_out_tab = "Log Out"

    @controller_action_name = controller_name.to_s+"-"+action_name.to_s
    @controller_name = controller_name.to_s
    @action_name = action_name.to_s
    @action_name_mm = action_name.to_s+"-"
    @action_name_mm = @action_name_mm.sub('-','')
    @current_main_nav = 1 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
    @mum_support_email = "mumsupport@ancillapartners.com"

    # MIPS TABS
    if @selected_mum_program_view == 2
      @aci_tab = 'PI'
      @quality_tab = 'Quality'
      # @resource_tab = 'Resource'
      @cpia_tab = 'CPIA'
      # @caphs_survey_tab = 'CAPHS Survey'
      @submission_tab = 'Submission'
      case controller_name
        when 'aci'
          @aci_tab = "<p class='nav_selected'>#{@aci_tab}</p>"
        when 'quality'
          @quality_tab = "<p class='nav_selected'>#{@quality_tab}</p>"
        when 'cpia'
          @cpia_tab = "<p class='nav_selected'>#{@cpia_tab}</p>"
        when 'submission'
          @submission_tab = "<p class='nav_selected'>#{@submission_tab}</p>"
      end

      @aco_quality_data_entry_tab = "ACO Quality Measure Data Entry"
      @aco_quality_data_entry_label = @aco_quality_data_entry_tab
    end

    if (controller_name == "home" or controller_name == "department_management_console")
      @home_tab = "<p class='nav_selected'>#{@home_tab}</p>"
      @current_main_nav = 1 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
    end
    if (controller_name == "group_requirement")
      if @selected_mum_program_view == 1
        @group_requirement_tab = "<p class='nav_selected'>#{@group_requirement_tab}</p>"
        @current_main_nav = 6 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      elsif @selected_mum_program_view == 2
        @admin_tab = "<p class='nav_selected'>#{@admin_tab}</p>"
        @group_requirement_tab = "<p class='subnav_selected'>#{@group_requirement_tab}</p>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
    end

    if (controller_name == "financial_management")
      @financial_management_tab = "<p class='nav_selected'>#{@financial_management_tab}</p>"
      @current_main_nav = 1 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
    end
    if (controller_name == "plan_manager_console")
      @plan_manager_console_tab = "<p class='nav_selected'>#{@plan_manager_console_tab}</p>"
      @current_main_nav = 4 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
    end
    if (controller_name == "action_plan")
      @action_plan_tab = "<p class='nav_selected'>#{@action_plan_tab}</p>"
      @current_main_nav = 4 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
    end
    if (controller_name == "utilities" && action_name == "help")
      @help_tab = "<p class='nav_selected'>#{@help_tab}</p>"
    end
    if (controller_name == "utilities" && action_name == "about")
      @about_tab = "<p class='nav_selected'>#{@about_tab}</p>"
    end
    if (controller_name == "utilities" &&  action_name == "edit_my_account")
      @my_account_tab = "<p class='nav_selected'>#{@my_account_tab}</p>"
    end

    if (controller_name == "mass_maintenance")
      @edit_tab = "<p class='nav_selected'>#{@edit_tab}</p>"
      if (action_name == "quick_entry")
        @quick_data_entry_tab = "<p class='subnav_selected'>#{@quick_data_entry_tab}</p>"
      elsif (action_name == "aco_quality_data_entry")
        @aco_quality_data_entry_tab = "<p class='subnav_selected'>#{@aco_quality_data_entry_tab}</p>"
      elsif(action_name == "index")
        @mass_data_entry_tab = "<p class='subnav_selected'>#{@mass_data_entry_tab}</p>"
      elsif(action_name == "add_attestation_history")
        @add_attestation_history_tab = "<p class='subnav_selected'>#{@add_attestation_history_tab}</p>"
      elsif(action_name == "actions")
        @mass_actions_tab = "<p class='subnav_selected'>#{@mass_actions_tab}</p>"
      elsif(action_name == "pecos_reconciliation")
        @pecos_reconciliation_tab = "<p class='subnav_selected'>#{@pecos_reconciliation_tab}</p>"
      elsif(action_name == "tin_quick_entry")
        @tin_quick_data_entry_tab = "<p class='subnav_selected'>#{@tin_quick_data_entry_tab}</p>"
      elsif(action_name == "interfaces")
        @interfaces_tab = "<p class='subnav_selected'>#{@interfaces_tab}</p>"
      elsif(action_name == "view_attest_ep" || action_name == "edit_attest_ep")
        @attest_ep_tab = "<p class='subnav_selected'>#{@attest_ep_tab}</p>"
      else
        @quick_data_entry_tab = "<p class='subnav_selected'>#{@quick_data_entry_tab}</p>"
      end
      @current_main_nav = 2 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
    end

    if (controller_name == "batch_attestation")
      @edit_tab = "<p class='nav_selected'>#{@edit_tab}</p>"
      @batch_attestation_tab = "<p class='subnav_selected'>#{@batch_attestation_tab}</p>"
      @current_main_nav = 2 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
    end

    if (controller_name == "report")
      @selected_report_id = (params[:selected_report_id] || 8).to_i
      @reports_tab = "<p class='nav_selected'>#{@reports_tab}</p>"
      @current_main_nav = 5 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
    end

    if (controller_name == "event") or (controller_name == "requirement") or (controller_name == "user" && @user.user_type_id.to_i == 1 ) or
        (controller_name == "group" && @user.user_type_id.to_i == 1 ) or (controller_name == "department" && @user.user_type_id.to_i == 1 ) or
        (controller_name == "attestation_clinic" && @user.user_type_id.to_i == 1 ) or
        (controller_name == "clinic" && @user.user_type_id.to_i == 1 ) or
        (controller_name == "pecos_clinic" && @user.user_type_id.to_i == 1 ) or
        (controller_name == "health_system" && @user.user_type_id.to_i == 1 ) or (controller_name == "group_actual_payment" && @user.user_type_id.to_i == 1) or
        (controller_name == "group_attestation_requirement_template" && @user.user_type_id.to_i == 1) or
        (controller_name == "criterion" && @user.user_type_id.to_i == 1 ) or (controller_name == "sub_criterion" && @user.user_type_id.to_i == 1 ) or
        (controller_name == "eligible_professional_type" && @user.user_type_id.to_i == 1 ) or
        (controller_name == "specialty" && @user.user_type_id.to_i == 1 ) or (controller_name == "meeting_status" && @user.user_type_id.to_i == 1 )
      (controller_name == "group_user_defined_value" && @user.user_type_id.to_i == 1 ) or
          (controller_name == "cms_update" && @user.user_type_id.to_i == 1 ) or  (controller_name == "messaging" && @user.user_type_id.to_i == 1 ) or
          (controller_name == "public_files" && @user.user_type_id.to_i == 1 ) or
          (controller_name == "global_cqm_template" && @user.user_type_id.to_i == 1 ) or
          (controller_name == "attestation_method" && @user.user_type_id.to_i == 1 ) or
          (controller_name == "upload" && @user.user_type_id.to_i == 1 ) or
          (controller_name == "batch_history" && @user.user_type_id.to_i == 1 ) or
          (controller_name == "splash_page" && @user.user_type_id.to_i == 1 ) or
          ((controller_name == "technology_vendor" || controller_name == "technology_product" || controller_name == "technology_module") && @user.user_type_id.to_i == 1 )
      @admin_tab = "<p class='nav_selected'>#{@admin_tab}</p>"
      if (controller_name == "group_attestation_requirement_template")
        @group_attestation_requirement_template_tab = "<span class='subnav_selected'>#{@group_attestation_requirement_template_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "event")
        @compliance_event_tab = "<span class='subnav_selected'>#{@compliance_event_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "requirement")
        @requirement_tab = "<span class='subnav_selected'>#{@requirement_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "user" && @user.user_type_id.to_i == 1 )
        @user_tab = "<span class='subnav_selected'>#{@user_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "group" && @user.user_type_id.to_i == 1 )
        @group_tab = "<span class='subnav_selected'>#{@group_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
        @current_main_controller = 2
      end
      if (controller_name == "department" && @user.user_type_id.to_i == 1 )
        @department_tab = "<span class='subnav_selected'>#{@department_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
        @current_main_controller = 5
      end
      if (controller_name == "attestation_clinic" && @user.user_type_id.to_i == 1 )
        @attestation_clinic_tab = "<span class='subnav_selected'>#{@attestation_clinic_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
        @current_main_controller = 4
      end
      if (controller_name == "clinic" && @user.user_type_id.to_i == 1 )
        @clinic_tab = "<span class='subnav_selected'>#{@clinic_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "pecos_clinic" && @user.user_type_id.to_i == 1 )
        @pecos_clinic_tab = "<span class='subnav_selected'>#{@pecos_clinic_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "health_system" && @user.user_type_id.to_i == 1 )
        @health_system_tab = "<span class='subnav_selected'>#{@health_system_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "group_actual_payment" && @user.user_type_id.to_i == 1)
        @group_actual_payment_tab = "<span class='subnav_selected'>#{@group_actual_payment_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "group_user_defined_value" && @user.user_type_id.to_i == 1 )
        @group_user_defined_values_tab = "<span class='subnav_selected'>#{@group_user_defined_values_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "criterion" && @user.user_type_id.to_i == 1 )
        @criterion_tab = "<span class='subnav_selected'>#{@criterion_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "sub_criterion" && @user.user_type_id.to_i == 1 )
        @sub_criterion_tab = "<span class='subnav_selected'>#{@sub_criterion_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "eligible_professional_type" && @user.user_type_id.to_i == 1 )
        @ep_type_tab = "<span class='subnav_selected'>#{@ep_type_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "specialty" && @user.user_type_id.to_i == 1 )
        @specialty_tab = "<span class='subnav_selected'>#{@specialty_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "meeting_status" && @user.user_type_id.to_i == 1 )
        @meeting_status_tab = "<span class='subnav_selected'>#{@meeting_status_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if ((controller_name == "technology_vendor" || controller_name == "technology_product" || controller_name == "technology_module") && @user.user_type_id.to_i == 1 )
        @technology_tab = "<span class='subnav_selected'>#{@technology_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "messaging" && @user.user_type_id.to_i == 1 )
        @messaging_tab = "<span class='subnav_selected'>#{@messaging_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "cms_update" && @user.user_type_id.to_i == 1 )
        @cms_update_tab = "<span class='subnav_selected'>#{@cms_update_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "public_files" && @user.user_type_id.to_i == 1 )
        @public_files_tab = "<span class='subnav_selected'>#{@public_files_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "global_cqm_template" && @user.user_type_id.to_i == 1 )
        @global_cqm_template_tab = "<span class='subnav_selected'>#{@global_cqm_template_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "attestation_method" && @user.user_type_id.to_i == 1 )
        @attestation_method_tab = "<span class='subnav_selected'>#{@attestation_method_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "upload" && @user.user_type_id.to_i == 1 )
        @upload_tab = "<span class='subnav_selected'>#{@upload_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == "batch_history" && @user.user_type_id.to_i == 1 )
        @batch_history_tab = "<span class='subnav_selected'>#{@batch_history_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
      if (controller_name == 'splash_page' && @user.user_type_id.to_i == 1 )
        @splash_page_tab = "<span class='subnav_selected'>#{@splash_page_tab}</span>"
        @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
      end
    end
    if (controller_name == "global_cqm_template" && @user.user_type_id.to_i == 1 )
      @global_cqm_template_tab = "<span class='subnav_selected'>#{@global_cqm_template_tab}</span>"
      @current_main_nav = 7 # 1=home, 2=data, 3=financials, 4=action items, 5=reports, 6=requirements 7=admin
    end
    @new_group_requirements = Requirement.new_group_requirements(@selected_group.id)
  end

  def authorize
    prepare_session
    if !session[:user_id].nil? && User.find_by_id(session[:user_id]) && User.find_by_id(session[:user_id]).active?
      #begin
      @user = User.find(session[:user_id].to_i)
      if session[:group_id].nil?
        @default_group = XUserGroup.find_by_user_id_and_status_and_active(@user.id, 1, 1)
        session[:group_id] = @default_group.group_id
      end
      if session[:attestation_clinic_id_portal].nil? || (params[:selected_group_id] && session[:group_id] != params[:selected_group_id].to_i)
        session[:attestation_clinic_id_portal] = -1
      end
      @default_group_id = session[:group_id]
      @selected_group_id = (params[:selected_group_id] || @default_group_id).to_i
      session[:group_id] = @selected_group_id
      @selected_user_group = XUserGroup.find_by_user_id(@user.id)
      @selected_groups = Group.GetFilteredGroupsBySecurity_Level(@user, @selected_user_group, @selected_user_group.group.health_system_id)
      @selected_group = Group.find(@selected_group_id)

      # if @selected_group.x_group_mum_programs.empty?
      #   default_group_mum_program = XGroupMumProgram.new
      #   default_group_mum_program.group_id = @selected_group.id
      #   default_group_mum_program.mum_program_id = 1
      #   default_group_mum_program.active = true
      #   group_mips_mum_program = XGroupMumProgram.new
      #   group_mips_mum_program.group_id = @selected_group.id
      #   group_mips_mum_program.mum_program_id = 2
      #   default_group_mum_program.save
      #   group_mips_mum_program.save
      # end
      if session[:mum_program_view].nil?
        session[:mum_program_view] = 2
      end
      if @default_group_id != @selected_group_id
        redirect_to root_path
      end
      if @default_group_id != @selected_group_id
        params[:selected_attestation_clinic_id_portal] = -1
      end
      @default_mum_program_view = session[:mum_program_view]
      @selected_mum_program_view = (params[:selected_mum_program_view] || @default_mum_program_view).to_i
      session[:mum_program_view] = @selected_mum_program_view

      @default_attestation_clinic_id_portal = session[:attestation_clinic_id_portal]
      @selected_attestation_clinic_id_portal = (params[:selected_attestation_clinic_id_portal] || @default_attestation_clinic_id_portal).to_i
      session[:attestation_clinic_id_portal] = @selected_attestation_clinic_id_portal

      @accepted_security_levels = [4]
      @accepted_user_types = [1, 2]
      if @accepted_security_levels.include? @user.security_level_id and @accepted_user_types.include? @user.user_type_id
        @selected_attestation_clinics_portal = AttestationClinic.AttestationClinics_By_GroupID_And_DepartmentOwnerID_And_DepartmentCount_for_select_in_form(@selected_group.id, @user.id)
      else
        @selected_attestation_clinics_portal = AttestationClinic.AttestationClinics_By_GroupID_And_DepartmentCount_for_select_in_form(@selected_group.id)
      end
      if @selected_attestation_clinics_portal.size == 1
        @selected_attestation_clinic_id_portal = @selected_attestation_clinics_portal.first[1]
      end

      @default_event_id = session[:event_id]
      @default_attestation_requirement_fiscal_year_id = session[:attestation_requirement_fiscal_year_id]
      @default_attestation_requirement_stage_id = session[:attestation_requirement_stage_id] || @selected_group.default_attestation_requirement_stage_id || -1

      @default_attestation_requirement_type_id = session[:attestation_requirement_type_id]
      @default_attestation_requirement_fiscal_year = {}
      if(@selected_group.group_type_id != 1 and @selected_group.group_type_id != 4)
        @default_attestation_requirement_fiscal_year = Event.event_fiscal_year_by_group_type_id_and_fiscal_year_and_attestation_requirement_type_id(@selected_group.group_type_id, determine_fiscal_year_based_on_current_date(@selected_group), @selected_group.attestation_requirement_type_flag)
        if @default_attestation_requirement_fiscal_year_id.nil? or @default_attestation_requirement_fiscal_year_id <= 0
          if @default_attestation_requirement_fiscal_year.nil?
            @default_attestation_requirement_fiscal_year = Event.event_fiscal_year_by_group_type_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_group.attestation_requirement_type_flag)
          end
          @default_attestation_requirement_fiscal_year_id = @default_attestation_requirement_fiscal_year.id.to_i
        end
      end
      if(@default_group_id != @selected_group_id) or ((params[:selected_event_id].nil? or params[:selected_event_id] == -1) and (session[:event_id].nil? or session[:event_id] == -1))
        if @default_group_id != @selected_group_id
          params[:selected_event_id] = nil
          params[:selected_attestation_requirement_fiscal_year_id] = nil
          params[:selected_attestation_requirement_stage_id] = (@selected_group.default_attestation_requirement_stage_id || nil)
          params[:selected_attestation_requirement_type_id] = nil
          session[:mass_maintenance_area_id] = nil
          params[:home_selected_attestation_requirement_fiscal_year_id] = nil
          params[:home_selected_attestation_requirement_stage_id] = (@selected_group.default_attestation_requirement_stage_id || nil)
          params[:home_selected_event_id] = nil
        end
        if @selected_group.group_type_id == 2
          @default_event = Event.events_by_group_and_group_type_id_and_fiscal_year(@selected_group, determine_fiscal_year_based_on_current_date(@selected_group))
          #@default_event = Event.event_by_group_type_id_and_fiscal_year_and_attestation_requirement_type_id(@selected_group.group_type_id, determine_fiscal_year_based_on_current_date(@selected_group), @selected_group.attestation_requirement_type_flag)
          if @default_event.nil?
            @default_event = Event.event_by_group_type_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_group.attestation_requirement_type_flag)
          end
          if @default_event.nil?
            session[:event_id] = nil
          else
            session[:event_id] = @default_event.id
          end
        else
          session[:event_id] = -1
        end
        @default_event_id = session[:event_id]
      end
      @selected_attestation_requirement_fiscal_year_id = (params[:selected_attestation_requirement_fiscal_year_id] || @default_attestation_requirement_fiscal_year_id).to_i
      @group_type_fiscal_start = ""
      @group_type_fiscal_end = ""
      if !@selected_attestation_requirement_fiscal_year_id.nil? and @selected_attestation_requirement_fiscal_year_id.to_i > 0
        @selected_attestation_requirement_fiscal_year = AttestationRequirementFiscalYear.find(@selected_attestation_requirement_fiscal_year_id)
        @group_type_fiscal_start = @selected_attestation_requirement_fiscal_year.name
        @group_type_fiscal_end = @selected_attestation_requirement_fiscal_year.name
        if @selected_group.group_type_id == 2
          @group_type_fiscal_start = (@group_type_fiscal_start.to_i - 1).to_s
        end
        @group_type_fiscal_start += "-"+@selected_group.group_type.fiscal_start.to_s
        @group_type_fiscal_end += "-"+@selected_group.group_type.fiscal_end.to_s

        x_group_year = XGroupYear.find_or_create_by(group_id: @selected_group.id,
                                                    attestation_requirement_fiscal_year_id: @selected_attestation_requirement_fiscal_year_id)
        session[:scaling_factor_base] = x_group_year.scaling_factor_base.to_s
        session[:scaling_factor_bonus] = x_group_year.scaling_factor_bonus.to_s
      end
      session[:attestation_requirement_fiscal_year_id] = @selected_attestation_requirement_fiscal_year_id
      @selected_attestation_requirement_stage_id = (params[:selected_attestation_requirement_stage_id] || @default_attestation_requirement_stage_id).to_i
      session[:attestation_requirement_stage_id] = @selected_attestation_requirement_stage_id
      @selected_attestation_requirement_type_id = (params[:selected_attestation_requirement_type_id] || 1).to_i
      session[:attestation_requirement_type_id] = @selected_attestation_requirement_type_id
      @selected_event_id = (params[:selected_event_id] || @default_event_id).to_i
      session[:event_id] = @selected_event_id

      @selected_events = Event.events_by_group_and_group_type_id_and_attestation_requirement_type_id(@selected_group) #events_by_group_type_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_group.attestation_requirement_type_flag)
      @selected_attestation_requirement_fiscal_years = Event.event_fiscal_years_by_group_type_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_group.attestation_requirement_type_flag)
      @selected_attestation_requirement_stages = Event.event_stages_by_group_type_id_and_attestation_requirement_fiscal_year_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_attestation_requirement_fiscal_year_id, @selected_group.attestation_requirement_type_flag)
      @selected_attestation_requirement_type = Event.event_types_by_group_type_id_and_attestation_requirement_fiscal_year_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_attestation_requirement_fiscal_year_id, @selected_group.attestation_requirement_type_flag)
      if @selected_group.group_type_id == 3 and @selected_attestation_requirement_stages.size == 1
        @selected_attestation_requirement_stage_id = @selected_attestation_requirement_stages.first[1].to_i
        session[:attestation_requirement_stage_id] = @selected_attestation_requirement_stage_id
      end

      if @selected_group.group_type_id == 3 && ((@default_attestation_requirement_fiscal_year_id.to_i != @selected_attestation_requirement_fiscal_year_id || @default_attestation_requirement_stage_id.to_i != @selected_attestation_requirement_stage_id) || params[:selected_attestation_requirement_stage_id].nil? || (@selected_attestation_requirement_stage_id > -1 && controller_name == "report" && params[:selected_report_id] != '8'))# and controller_name != "report"
        physician_event = Event.where(["group_type_id = ? and attestation_requirement_fiscal_year_id = ? and attestation_requirement_stage_id = ? and attestation_requirement_type_id = ?", @selected_group.group_type_id, @selected_attestation_requirement_fiscal_year_id, @selected_attestation_requirement_stage_id, @selected_attestation_requirement_type_id]).first
        if physician_event.nil? and (@selected_attestation_requirement_stages.size == 1 or (action_name != 'dashboard' and controller_name != 'home' and controller_name != 'aci' and controller_name != 'quality' and controller_name != 'batch_history' and (controller_name + action_name != 'cpiaaco_aggregation')) or @selected_attestation_requirement_stage_id > 0)  #or (@selected_attestation_requirement_stage_id.to_i == -1 and (controller_name == "requirement" or controller_name = "group_requirement")
          @first_selected_attestation_requirement_stage = Event.event_stage_by_group_type_id_and_attestation_requirement_fiscal_year_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_attestation_requirement_fiscal_year_id, @selected_group.attestation_requirement_type_flag)
          @selected_attestation_requirement_stage_id = @first_selected_attestation_requirement_stage.id.to_i
          session[:attestation_requirement_stage_id] = @selected_attestation_requirement_stage_id
        end
        physician_event = Event.where(["group_type_id = ? and attestation_requirement_fiscal_year_id = ? and attestation_requirement_stage_id = ? and attestation_requirement_type_id = ?", @selected_group.group_type_id, @selected_attestation_requirement_fiscal_year_id, @selected_attestation_requirement_stage_id, @selected_attestation_requirement_type_id]).first

        @selected_event_id = ((physician_event.nil?) ? -1 : physician_event.id).to_i
        session[:event_id] = @selected_event_id
      end

      if @user.user_type_id == 1 and [1, 2, 3, 6].include?(@user.security_level_id)
        if @selected_group.group_type_id == 1 or @selected_group.group_type_id == 4
          @current_batch_jobs = JobHistory.where(job_status: ['Queued', 'Processing']).count
        else
          @current_batch_jobs = JobHistory.where(group_id: @selected_group.id, job_status: ['Queued', 'Processing']).count
        end
      end

      @url_host = request.env["HTTP_HOST"]
      if @selected_mum_program_view == 2
        @main_image = "/images/logos/MACRALoginLogo.png"
        # @main_image = "/images/logos/MIPSLoginLogo.png"
      else
        @main_image = "/images/logos/MUMLoginLogo.jpg"
      end
      if(@url_host == "icd10.meaningfulusemonitor.net")
        #@main_image = "/images/logos/ICD10PortalLogo.png"
        @main_image = "/images/logos/CustomerConciergeMonitorLogo.png"
      end
      #@logo_image = "/images/logos/"+((@selected_group.business_partner.nil?) ? "MUMLogoColorShort.gif" : @selected_group.business_partner.logo_image || "MUMLogoColorShort.gif")

      @logo_image = ((!@selected_group.business_partner.nil? and !@selected_group.business_partner.logo.nil?) ? @selected_group.business_partner.logo.public_filename : '')

      #rescue ActiveRecord::RecordNotFound
      #  flash[:notice] = "Logged in user not found"
      #  redirect_to :controller => "login", :action => "index"
      #end
    else
      flash[:notice] = "<span class='yes'>Please Log In</span>"
      session[:original_uri] = request.url
      redirect_to(login_url)
    end
  end

  def is_ambulatory
    redirect_to :controller => :home if @selected_group.group_type_id != 3
  end

  def authorize_http_basic
    @user = nil
    authenticate_with_http_basic do |id, password|
      @user = User.authenticate(id, password)
    end
    if (@user.nil?)
      render :nothing => true, :status => '401 Unauthorized'
    else
      @user_group = XUserGroup.find_by_user_id_and_status_and_active(@user.id, 1, 1)
      @group = @user_group.group
    end
    #@logo_image = ((!@selected_group.business_partner.nil? and !@selected_group.business_partner.logo_image.nil?) ? "/images/logos/"+@selected_group.business_partner.logo_image.to_s : '')
  end

  def authorize_admin
    prepare_session
    # unless can find a user and that user has true (1) for it's health_system.NotAHealthSystem value
    if User.find_by_id(session[:user_id]) && User.find_by_id(session[:user_id]).active? && User.find_by_id(session[:user_id]).status? && User.find_by_id(session[:user_id]).user_type_id.to_i == 1
      begin
        @user = User.find(session[:user_id].to_i)
        if session[:group_id].nil?
          @default_group = XUserGroup.find_by_user_id_and_status_and_active(@user.id, 1, 1)
          session[:group_id] = @default_group.group_id
        end
        if session[:attestation_clinic_id_portal].nil? || session[:group_id] != params[:selected_group_id].to_i
          session[:attestation_clinic_id_portal] = -1
        end
        @default_group_id = session[:group_id]
        @selected_group_id = (params[:selected_group_id] || @default_group_id).to_i
        session[:group_id] = @selected_group_id
        @selected_event_id = (params[:selected_event_id] || -1).to_i
        @selected_user_group = XUserGroup.find_by_user_id(@user.id)
        @selected_groups = Group.GetFilteredGroupsBySecurity_Level(@user, @selected_user_group, @selected_user_group.group.health_system_id)
        @selected_group = Group.find(@selected_group_id)

        # if @selected_group.x_group_mum_programs.empty?
        #   default_group_mum_program = XGroupMumProgram.new
        #   default_group_mum_program.group_id = @selected_group.id
        #   default_group_mum_program.mum_program_id = 1
        #   default_group_mum_program.active = true
        #   group_mips_mum_program = XGroupMumProgram.new
        #   group_mips_mum_program.group_id = @selected_group.id
        #   group_mips_mum_program.mum_program_id = 2
        #   default_group_mum_program.save
        #   group_mips_mum_program.save
        # end
        if session[:mum_program_view].nil?
          # session[:mum_program_view] = @selected_group.preferred_mum_program_id
          session[:mum_program_view] = 2
        end
        if @default_group_id != @selected_group_id
          redirect_to root_path
        end
        if @default_group_id != @selected_group_id
          params[:selected_attestation_clinic_id_portal] = -1
        end
        @default_mum_program_view = session[:mum_program_view]
        @selected_mum_program_view = (params[:selected_mum_program_view] || @default_mum_program_view).to_i
        session[:mum_program_view] = @selected_mum_program_view

        @default_attestation_clinic_id_portal = session[:attestation_clinic_id_portal]
        @selected_attestation_clinic_id_portal = (params[:selected_attestation_clinic_id_portal] || @default_attestation_clinic_id_portal).to_i
        session[:attestation_clinic_id_portal] = @selected_attestation_clinic_id_portal

        @accepted_security_levels = [4]
        @accepted_user_types = [1, 2]
        if @accepted_security_levels.include? @user.security_level_id and @accepted_user_types.include? @user.user_type_id
          @selected_attestation_clinics_portal = AttestationClinic.AttestationClinics_By_GroupID_And_DepartmentOwnerID_And_DepartmentCount_for_select_in_form(@selected_group.id, @user.id)
        else
          @selected_attestation_clinics_portal = AttestationClinic.AttestationClinics_By_GroupID_And_DepartmentCount_for_select_in_form(@selected_group.id)
        end
        if @selected_attestation_clinics_portal.size == 1
          @selected_attestation_clinic_id_portal = @selected_attestation_clinics_portal.first[1]
        end

        @default_event_id = session[:event_id]
        @default_attestation_requirement_fiscal_year_id = session[:attestation_requirement_fiscal_year_id]
        @default_attestation_requirement_stage_id = session[:attestation_requirement_stage_id] || @selected_group.default_attestation_requirement_stage_id || -1
        @default_attestation_requirement_type_id = session[:attestation_requirement_type_id]
        @default_attestation_requirement_fiscal_year = {}
        if(@selected_group.group_type_id != 1 and @selected_group.group_type_id != 4)
          @default_attestation_requirement_fiscal_year = Event.event_fiscal_year_by_group_type_id_and_fiscal_year_and_attestation_requirement_type_id(@selected_group.group_type_id, determine_fiscal_year_based_on_current_date(@selected_group), @selected_group.attestation_requirement_type_flag)
          if @default_attestation_requirement_fiscal_year_id.nil? or @default_attestation_requirement_fiscal_year_id <= 0
            if @default_attestation_requirement_fiscal_year.nil?
              @default_attestation_requirement_fiscal_year = Event.event_fiscal_year_by_group_type_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_group.attestation_requirement_type_flag)
            end
            @default_attestation_requirement_fiscal_year_id = @default_attestation_requirement_fiscal_year.id.to_i
          end
        end
        if(@default_group_id != @selected_group_id) or ((params[:selected_event_id].nil? or params[:selected_event_id] == -1) and (session[:event_id].nil? or session[:event_id] == -1))
          if @default_group_id != @selected_group_id
            params[:selected_event_id] = nil
            params[:selected_attestation_requirement_fiscal_year_id] = nil
            params[:selected_attestation_requirement_stage_id] = (@selected_group.default_attestation_requirement_stage_id || nil)
            params[:selected_attestation_requirement_type_id] = nil
            params[:home_selected_attestation_requirement_fiscal_year_id] = nil
            params[:home_selected_attestation_requirement_stage_id] = (@selected_group.default_attestation_requirement_stage_id || nil)
            params[:home_selected_event_id] = nil
          end
          if @selected_group.group_type_id == 2
            @default_event = Event.events_by_group_and_group_type_id_and_fiscal_year(@selected_group, determine_fiscal_year_based_on_current_date(@selected_group))
            # @default_event = Event.event_by_group_type_id_and_fiscal_year_and_attestation_requirement_type_id(@selected_group.group_type_id, determine_fiscal_year_based_on_current_date(@selected_group), @selected_group.attestation_requirement_type_flag)
            if @default_event.nil?
              @default_event = Event.event_by_group_type_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_group.attestation_requirement_type_flag)
            end
            if @default_event.nil?
              session[:event_id] = nil
            else
              session[:event_id] = @default_event.id
            end
          else
            session[:event_id] = -1
          end
          @default_event_id = session[:event_id]
        end
        @selected_attestation_requirement_fiscal_year_id = (params[:selected_attestation_requirement_fiscal_year_id] || @default_attestation_requirement_fiscal_year_id).to_i
        @group_type_fiscal_start = ""
        @group_type_fiscal_end = ""
        if !@selected_attestation_requirement_fiscal_year_id.nil? and @selected_attestation_requirement_fiscal_year_id.to_i > 0
          @selected_attestation_requirement_fiscal_year = AttestationRequirementFiscalYear.find(@selected_attestation_requirement_fiscal_year_id)
          @group_type_fiscal_start = @selected_attestation_requirement_fiscal_year.name
          @group_type_fiscal_end = @selected_attestation_requirement_fiscal_year.name
          if @selected_group.group_type_id == 2
            @group_type_fiscal_start = (@group_type_fiscal_start.to_i - 1).to_s
          end
          @group_type_fiscal_start += "-"+@selected_group.group_type.fiscal_start.to_s
          @group_type_fiscal_end += "-"+@selected_group.group_type.fiscal_end.to_s

          x_group_year = XGroupYear.find_or_create_by_group_id_and_attestation_requirement_fiscal_year_id(@selected_group.id, @selected_attestation_requirement_fiscal_year_id)
          session[:scaling_factor_base] = x_group_year.scaling_factor_base.to_s
          session[:scaling_factor_bonus] = x_group_year.scaling_factor_bonus.to_s
        end

        session[:attestation_requirement_fiscal_year_id] = @selected_attestation_requirement_fiscal_year_id
        @selected_attestation_requirement_stage_id = (params[:selected_attestation_requirement_stage_id] || @default_attestation_requirement_stage_id).to_i
        session[:attestation_requirement_stage_id] = @selected_attestation_requirement_stage_id
        @selected_attestation_requirement_type_id = (params[:selected_attestation_requirement_type_id] || 1).to_i
        session[:attestation_requirement_type_id] = @selected_attestation_requirement_type_id
        @selected_event_id = (params[:selected_event_id] || @default_event_id).to_i
        session[:event_id] = @selected_event_id

        @selected_events = Event.events_by_group_and_group_type_id_and_attestation_requirement_type_id(@selected_group) #events_by_group_type_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_group.attestation_requirement_type_flag)
        @selected_attestation_requirement_fiscal_years = Event.event_fiscal_years_by_group_type_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_group.attestation_requirement_type_flag)
        @selected_attestation_requirement_stages = Event.event_stages_by_group_type_id_and_attestation_requirement_fiscal_year_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_attestation_requirement_fiscal_year_id, @selected_group.attestation_requirement_type_flag)
        @selected_attestation_requirement_type = Event.event_types_by_group_type_id_and_attestation_requirement_fiscal_year_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_attestation_requirement_fiscal_year_id, @selected_group.attestation_requirement_type_flag)
        if @selected_group.group_type_id == 3 and @selected_attestation_requirement_stages.size == 1
          @selected_attestation_requirement_stage_id = @selected_attestation_requirement_stages.first[1].to_i
          session[:attestation_requirement_stage_id] = @selected_attestation_requirement_stage_id
        end

        if @selected_group.group_type_id == 3
          physician_event = Event.where(["group_type_id = ? and attestation_requirement_fiscal_year_id = ? and attestation_requirement_stage_id = ? and attestation_requirement_type_id = ?", @selected_group.group_type_id, @selected_attestation_requirement_fiscal_year_id, @selected_attestation_requirement_stage_id, @selected_attestation_requirement_type_id]).first
          if physician_event.nil? and (action_name != 'dashboard' or @selected_attestation_requirement_stage_id > 0) #or (@selected_attestation_requirement_stage_id.to_i == -1 and (controller_name == "requirement" or controller_name = "group_requirement")
            @first_selected_attestation_requirement_stage = Event.event_stage_by_group_type_id_and_attestation_requirement_fiscal_year_id_and_attestation_requirement_type_id(@selected_group.group_type_id, @selected_attestation_requirement_fiscal_year_id, @selected_group.attestation_requirement_type_flag)
            @selected_attestation_requirement_stage_id = @first_selected_attestation_requirement_stage.id.to_i
            session[:attestation_requirement_stage_id] = @selected_attestation_requirement_stage_id
          end
          physician_event = Event.where(["group_type_id = ? and attestation_requirement_fiscal_year_id = ? and attestation_requirement_stage_id = ? and attestation_requirement_type_id = ?", @selected_group.group_type_id, @selected_attestation_requirement_fiscal_year_id, @selected_attestation_requirement_stage_id, @selected_attestation_requirement_type_id]).firstt

          @selected_event_id = ((physician_event.nil?) ? -1 : physician_event.id).to_i
          session[:event_id] = @selected_event_id
        end

        if @user.user_type_id == 1 and [1, 2, 3, 6].include?(@user.security_level_id)
          if @selected_group.group_type_id == 1 or @selected_group.group_type_id == 4
            @current_batch_jobs = JobHistory.find_all_by_job_status(['Queued', 'Processing']).size
          else
            @current_batch_jobs = JobHistory.find_all_by_group_id_and_job_status(@selected_group.id, ['Queued', 'Processing']).size
          end
        end

        @url_host = request.env["HTTP_HOST"]
        if @selected_mum_program_view == 2
          @main_image = "/images/logos/MACRALoginLogo.png"
          # @main_image = "/images/logos/MIPSLoginLogo.png"
        else
          @main_image = "/images/logos/MUMLoginLogo.jpg"
        end
        if(@url_host == "icd10.meaningfulusemonitor.net")
          #@main_image = "/images/logos/ICD10PortalLogo.png"
          @main_image = "/images/logos/CustomerConciergeMonitorLogo.png"
        end
        #@logo_image = "/images/logos/"+((@selected_group.business_partner.nil?) ? "MUMLogoColorShort.gif" : @selected_group.business_partner.logo_image || "MUMLogoColorShort.gif")
        @logo_image = ((!@selected_group.business_partner.nil? and !@selected_group.business_partner.logo.nil?) ? @selected_group.business_partner.logo.public_filename : '')

        if @user.security_level_id == 2
          accepted_controllers = ["group", "attestation_clinic", "clinic", "pecos_clinic", "user", "department", "group_user_defined_value", "mass_maintenance", "group_actual_payment", "group_attestation_requirement_template"]
          if !accepted_controllers.include? controller_name.to_s
            redirect_to :controller => :group, :action => :index
          end
        end
        if @user.security_level_id == 3
          accepted_controllers = ["group", "attestation_clinic", "clinic", "pecos_clinic", "user", "department", "group_user_defined_value", "mass_maintenance", "group_actual_payment", "group_attestation_requirement_template"]
          if !accepted_controllers.include? controller_name.to_s
            redirect_to :controller => :group, :action => :index
          end
        end
        if @user.security_level_id == 4
          accepted_controllers = []
          if !accepted_controllers.include? controller_name.to_s
            redirect_to :controller => :home, :action => :index
          end
        end
        if @user.security_level_id == 5
          accepted_controllers = []
          if !accepted_controllers.include? controller_name.to_s
            redirect_to :controller => :event, :action => :index
          end
        end
        if @user.security_level_id == 6
          accepted_controllers = ["health_system", "group", "attestation_clinic", "clinic", "pecos_clinic", "user", "department", "group_user_defined_value", "mass_maintenance", "group_actual_payment", "group_attestation_requirement_template"]
          if !accepted_controllers.include? controller_name.to_s
            redirect_to :controller => :group, :action => :index
          end
        end

      rescue ActiveRecord::RecordNotFound
        flash[:notice] = "Logged in user not found"
        redirect_to(login_url)
      end
    else
      flash[:notice] = "<span class='yes'>Please Log In</span>"
      session[:original_uri] = request.url
      redirect_to(login_url)
    end
  end


  def prepare_session
    @max_session_time = MAX_SESSION_TIME.seconds
    current_time = Time.zone.now #user_time_zone_now
    if !session[:expiry_time].nil? and session[:expiry_time] < current_time #Time.zone.now
      # Session has expired. Clear the current session.
      reset_session
    end

    # Assign a new expiry time, whether the session has expired or not.
    session[:expiry_time] =  MAX_SESSION_TIME.seconds.from_now #current_time + MAX_SESSION_TIME.seconds #.from.@current_time
    session[:expiry_time_server] = MAX_SESSION_TIME.seconds.from_now
    return true
  end

  def determine_fiscal_year_based_on_current_date(group_type)
    current_time = Time.zone.now
    temp_fiscal_year = current_time.year
    if group_type.id == 2
      if current_time.month.to_i >= group_type.fiscal_start.to_s[1..2].to_i
        temp_fiscal_year += 1
      end
    end
    return temp_fiscal_year
  end
  def resolve_layout
    # "portal" + ((@selected_mum_program_view == 2) ? @selected_group.theme.layout_name : '')
    "portal"
  end
  def resolve_pop_up_layout
    "pop_up" + ((@selected_mum_program_view == 2) ? @selected_group.theme.layout_name : '')
  end
end
