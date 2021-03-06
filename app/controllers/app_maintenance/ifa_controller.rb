class AppMaintenance::IfaController < AppMaintenance::ApplicationController

  layout "ifa_maint", :except =>[:standard_select, :add_remove_standard_option]

  before_filter :set_ifa, :except=>[]
  before_filter :current_org_current_app_provider?, :except=>[]
  before_filter :current_user_app_superuser?, :except => []
  before_filter :clear_notification, :except => []
  before_filter :current_standard, :except => []
  before_filter :current_subject, :except => []
  before_filter :subjects, :except => [:strategy_add, :strategy_create, :strategy_select]
  before_filter :enabled_subjects, :only => [:strategy_add, :strategy_create, :strategy_select]
  before_filter :current_ifa_options
  before_filter :prep_classrooms

  def index
    standards
    strategies
    strands
    active_strands
    current_strand
    levels
    active_levels
    benchmark_dashboard
    current_level
  end

  def strategy_select
    get_strategy
    strategies
    render :partial =>  "manage_strategies", :locals=>{}
  end

  def strategy_add
    @current_strategy = ActStrategy.new
  end

  def strategy_create
    @current_strategy = ActStrategy.new
    @current_strategy.name = params[:act_strategy][:name]
    @current_strategy.pos = params[:act_strategy][:pos]
    @current_strategy.description = params[:act_strategy][:description]
    @current_strategy.act_subject_id = params[:act_strategy][:act_subject_id]
    @current_strategy.is_active = params[:act_strategy][:is_active]
    @current_strategy.is_default = params[:act_strategy][:is_default]
    if @current_strategy.save
      flash[:notice] = "Strategy Created"
    else
      flash[:error] = @current_strategy.errors.full_messages.to_sentence
    end
    render :strategy_add
  end

  def strategy_update
    get_strategy
    @current_strategy.update_attributes(:name=>params[:name], :is_active => (params[:is_active].upcase == 'Y' ? true:false),
                                        :is_default => (params[:is_default].upcase == 'Y' ? true:false), :description=>params[:description], :pos => params[:pos])
    render :partial =>  "edit_strategy", :locals=>{:strategy => @current_strategy}
  end

  def strategy_destroy
    get_strategy
    strategies
    if @current_strategy && @current_strategy.destroyable?
      if @current_strategy.destroy
        flash[:notice] = "Strategy Destroyed"
      end
    end
    @current_strategy = nil
    render :partial =>  "manage_strategies", :locals=>{}
  end

  def standard_maint_select
    standards
    render :partial =>  "manage_standards", :locals=>{}
  end

  def standard_update
    if params[:is_default] == 'Y'
      ActMaster.all_defaults.each do |std|
        std.update_attributes(:is_default => false)
      end
    end
    @current_standard.update_attributes(:name=>params[:name], :is_national => (params[:national] == 'Y' ? true:false),
                                        :abbrev=>params[:abbrev], :is_default => (params[:is_default] == 'Y' ? true:false),
                                        :source=>params[:source], :abbrev_old => params[:abbrev_old])
    render :partial =>  "edit_standard", :locals=>{:standard => @current_standard}
  end

  def standard_add
    @current_standard = ActMaster.new
  end

  def standard_create
    @current_standard = ActMaster.new
    @current_standard.name = params[:act_master][:name]
    @current_standard.abbrev = params[:act_master][:abbrev].upcase
    @current_standard.abbrev_old = @current_standard.abbrev
    @current_standard.source = params[:act_master][:source]
    @current_standard.is_default = false
    @current_standard.is_national = params[:act_master][:is_national]
    if @current_standard.save
      flash[:notice] = "Standard Created"
    else
      flash[:error] = @current_standard.errors.full_messages.to_sentence
    end
    render :standard_add
  end

  def standard_destroy
    current_standard
    if @current_standard != @current_provider.master_standard && @current_standard.destoyable?
      if @current_standard.destroy
        flash[:notice] = "Standard Destroyed"
        @current_standard = @current_provider.master_standard
      end
    end
    standards
    render :partial =>  "manage_standards", :locals=>{}
  end

  def standard_select
    standards
    strategies
    strands
    current_strand
    levels
    active_strands
    active_levels
    benchmark_dashboard
    render :partial =>  "manage_standard", :locals=>{}
  end

  def strand_add
    @strand = ActStandard.new
  end

  def strand_create
    @strand = ActStandard.new
    @strand.name = params[:act_standard][:name]
    @strand.abbrev = params[:act_standard][:abbrev]
    @strand.description = params[:act_standard][:description]
    @strand.strand_background = params[:act_standard][:strand_background]
    @strand.strand_font = params[:act_standard][:strand_font]
    @strand.pos = params[:act_standard][:pos]
    @strand.is_active = params[:act_standard][:is_active]
    @strand.act_subject_id = @current_subject.id
    @strand.act_master_id = @current_standard.id
    if @strand.save
      flash[:notice] = "Strand Created"
    else
      flash[:error] = @strand.errors.full_messages.to_sentence
    end
    render :strand_add
  end

  def strand_select
    strands
    current_strand
    render :partial =>  "manage_strands", :locals=>{}
  end

  def bench_level_change
    cell_strand
    cell_level
    active_strands
    active_levels
    current_benchmark
    @current_benchmark.update_attributes(:act_score_range_id => params[:new_range_id])
    benchmark_dashboard
    render :partial =>  "manage_benchmarks_cell", :locals=>{:strand => @cell_strand, :level => @cell_level}
  end

  def bench_strand_change
    cell_strand
    cell_level
    active_strands
    active_levels
    current_benchmark
    @current_benchmark.update_attributes(:act_standard_id => params[:new_strand_id])
    benchmark_dashboard
    render :partial =>  "manage_benchmarks_cell", :locals=>{:strand => @cell_strand, :level => @cell_level}
  end

  def bench_cell_select
    active_strands
    active_levels
    cell_strand
    cell_level
    benchmark_dashboard
    #  current_strand_benchmarks(:level => @cell_level)
    render :partial =>  "manage_benchmarks", :locals=>{}
  end

  def benchmark_view_close
    active_strands
    active_levels
    benchmark_dashboard
    render :partial =>  "manage_benchmarks", :locals=>{}
  end

  def bench_strand_select_x
    active_strands
    active_levels
    get_strand
    benchmark_dashboard
    current_strand_benchmarks
    render :partial =>  "manage_benchmarks", :locals=>{}
  end

  def bench_level_select_x
    active_levels
    active_strands
    get_level
    benchmark_dashboard
    current_level_benchmarks
    render :partial =>  "manage_benchmarks", :locals=>{}
  end


  def strand_update
    strands
    current_strand
    @current_strand.update_attributes(:name=>params[:name], :abbrev => params[:abbrev], :description=>params[:description],
                                      :strand_background=>params[:strand_background], :strand_font=>params[:strand_font], :pos=>params[:pos])
    render :partial =>  "edit_strand", :locals=>{:strand => @current_strand}
  end

  def strand_toggle
    strands
    current_strand
    @current_strand.update_attributes(:is_active=> !@current_strand.is_active)
    render :partial =>  "edit_strand", :locals=>{:strand => @current_strand}
  end

  def strand_destroy
    strands
    current_strand
    if @current_strand.destroyable?
      if @current_strand.destroy
        flash[:notice] = "Strand Destroyed"
        strands
        @current_strand = @strands.first rescue nil
      end
    end
    render :partial =>  "edit_strand", :locals=>{:strand => @current_strand}
  end

  def subject_update
    @subject = ActSubject.find_by_id(params[:subject_id]) rescue nil
    @subject.update_attributes(:name=>params[:name], :is_plannable => (params[:is_plannable] == 'Y' ? true:false), :is_enabled => (params[:is_active] == 'Y' ? true:false),
                               :posit => params[:position], :question_time => params[:question_time])
    render :partial =>  "edit_subject", :locals=>{:subject => @subject}
  end

  def genre_create
    ActGenre.create(:name=>params[:name], :description=>params[:description])
    render :partial =>  "manage_genres"
  end

  def genre_update
    @genre = ActGenre.find_by_id(params[:act_genre_id]) rescue nil
    @genre.update_attributes(:name=>params[:name], :description=>params[:description], :is_active => (params[:is_active].upcase == 'Y' ? true:false))
    render :partial =>  "edit_genre", :locals=>{:genre => @genre}
  end

  def level_select
    levels
    current_level
    render :partial =>  "manage_levels", :locals=>{}
  end

  def level_add
    sat_map
    @current_level = ActScoreRange.new
  end

  def level_create
    @current_level = ActScoreRange.new
    @current_level.act_subject_id = @current_subject.id
    @current_level.act_master_id = @current_standard.id
    @current_level.range = params[:act_score_range][:range]
    @current_level.lower_score = params[:act_score_range][:lower_score]
    @current_level.upper_score = params[:act_score_range][:upper_score]
    if sat_map_input?(params[:sat_map][:lower], params[:sat_map][:upper])
      sat_map =get_sat_map_id(params[:sat_map][:lower].to_i, params[:sat_map][:upper].to_i)
      @current_level.act_sat_map_id = sat_map.nil? ? nil : sat_map.id
    end
    @current_level.score_background = params[:act_score_range][:score_background]
    @current_level.score_font = params[:act_score_range][:score_font]
    @current_level.is_active = params[:act_score_range][:is_active]
    if @current_level.save
      flash[:notice] = "Level Created"
    else
      flash[:error] = @current_level.errors.full_messages.to_sentence
    end
    render :level_add
  end

  def level_update
    levels
    current_level
    if sat_map_input?(params[:sat_map_lower], params[:sat_map_upper])
      sat_map =get_sat_map_id(params[:sat_map_lower].to_i, params[:sat_map_upper].to_i)
      sat_map_id = sat_map.nil? ? nil : sat_map.id
    else
      sat_map_id = nil
    end
    @current_level.update_attributes(:range=>params[:range], :lower_score => params[:lower_score], :upper_score => params[:upper_score],
                                     :score_background=>params[:score_background], :score_font=>params[:score_font], :act_sat_map_id => sat_map_id)
    render :partial =>  "edit_level", :locals=>{:level => @current_level}
  end

  def level_toggle
    levels
    current_level
    @current_level.update_attributes(:is_active=> !@current_level.is_active)
    render :partial =>  "edit_level", :locals=>{:level => @current_level}
  end

  def level_destroy
    levels
    current_level
    if @current_level.destroyable?
      if @current_level.destroy
        flash[:notice] = "Level Destroy"
        levels
        @current_level = @levels.first rescue nil
      end
    end
    render :partial =>  "edit_level", :locals=>{:level => @current_level}
  end

  def benchmark_refresh
    get_strand
    active_strands
    active_levels
    current_strand_benchmarks
    render :partial =>  "manage_benchmarks_strand", :locals=>{:strand => @current_strand, :levels => @active_levels, :strands => @active_strands}
  end

  def benchmark_refresh_l
    get_level
    active_strands
    active_levels
    current_level_benchmarks
    render :partial =>  "manage_benchmarks_level", :locals=>{:level => @current_level, :levels => @active_levels, :strands => @active_strands}
  end

  def benchmark_dashboard_refresh
    active_strands
    active_levels
    benchmark_dashboard
    render :partial =>  "benchmark_dashboard"
  end

  def benchmark_toggle
    current_benchmark
    active_levels
    active_strands
    if params[:function] == 'Active'
      @current_benchmark.update_attributes(:is_active=> !@current_benchmark.is_active)
    elsif params[:function] == 'View'
      @current_benchmark.update_attributes(:is_s_viewable=> !@current_benchmark.is_s_viewable)
    elsif params[:function] == 'Tag'
      @current_benchmark.update_attributes(:is_q_taggable=> !@current_benchmark.is_q_taggable)
    end
    render :partial =>  "show_benchmark",  :locals=>{:strand => @current_benchmark.strand, :level => @current_benchmark.mastery_level,
                                                     :levels => @active_levels, :strands => @active_strands, :by => params[:by],
                                                     :benchmark => @current_benchmark, :benchmark_id => @current_benchmark.public_id}
  end

  def benchmark_destroy
    current_benchmark
    active_levels
    active_strands
    strand = @current_benchmark.strand
    level = @current_benchmark.mastery_level
    benchmark_id = @current_benchmark.public_id
    if @current_benchmark.destroy
      flash[:notice] = "Benchmark Destroyed"
    end
    render :partial =>  "show_benchmark",  :locals=>{:strand => strand, :level => level, :strands => @active_strands, :levels => @active_levels, :benchmark => nil, :benchmark_id => benchmark_id, :by => params[:by]}
  end

  def benchmark_standard_select
    current_benchmark
    @benchmark_standard = ActMaster.find_by_id(params[:bench_standard_id]) rescue nil
    benchmark_source_standards
    @current_benchmark ||= ActBench.new
    render :partial => "benchmark_source"
  end

  def benchmark_add
    get_strand
    get_level
    @benchmark_standard = nil
    benchmark_source_standards
    @bench_types = @current_level.standard.act_bench_types
    @current_benchmark = ActBench.new
    set_default_bench_type(@current_benchmark)
  end

  def benchmark_edit
    get_strand
    get_level
    current_benchmark
    @benchmark_standard = @current_benchmark.other_source_standard
    benchmark_source_standards
    @bench_types = @current_level.standard.act_bench_types
  end

  def benchmark_create
    get_strand
    get_level
    @bench_types = @current_level.standard.act_bench_types
    @current_benchmark = ActBench.new
    @current_benchmark.act_master_id = @current_level.standard.id
    @current_benchmark.act_subject_id = @current_level.subject_area.id
    @current_benchmark.act_standard_id = @current_strand.id
    @current_benchmark.act_score_range_id = @current_level.id
    @current_benchmark.user_id = @current_user.id
    @current_benchmark.organization_id = @current_organization.id
    @current_benchmark.description = params[:act_bench][:description]
    @current_benchmark.is_active = true
    get_source_level_strand_ids
    @current_benchmark.source_level_id = @source_level_id
    @current_benchmark.source_strand_id = @source_strand_id
    if params[:act_bench][:act_benchmark_type_id] == ''
      set_default_bench_type(@current_benchmark)
    else
      @current_benchmark.act_bench_type_id = params[:act_bench][:act_benchmark_type_id]
    end
    @current_benchmark.pos = params[:act_bench][:pos]
    if @current_benchmark.save
      flash[:notice] = "Benchmark Created"
      @current_benchmark = ActBench.new
    else
      flash[:error] = @current_benchmark.errors.full_messages.to_sentence
    end
    @benchmark_standard = @current_benchmark.other_source_standard
    benchmark_source_standards
    render :benchmark_add
  end

  def benchmark_update
    get_strand
    get_level
    current_benchmark
    @bench_types = @current_level.standard.act_bench_types
    @current_benchmark.user_id = @current_user.id
    @current_benchmark.organization_id = @current_organization.id
    @current_benchmark.description = params[:act_bench][:description]
    get_source_level_strand_ids
    @current_benchmark.source_level_id = @source_level_id
    @current_benchmark.source_strand_id = @source_strand_id
    if params[:act_bench][:act_benchmark_type_id] != ''
      @current_benchmark.act_bench_type_id = params[:act_bench][:act_benchmark_type_id]
    end
    @current_benchmark.pos = params[:act_bench][:pos]
    if @current_benchmark.save
      flash[:notice] = "Benchmark Updated"
    else
      flash[:error] = @current_benchmark.errors.full_messages.to_sentence
    end
    @benchmark_standard = @current_benchmark.other_source_standard
    benchmark_source_standards
    render :benchmark_edit
  end

  # Options

  def add_remove_standard_option
    master = ActMaster.find_by_public_id(params[:master_id]) rescue nil
    if !@current_provider.ifa_org_option.act_masters.include?(master)
      @current_provider.ifa_org_option.act_masters << master
    else
      remove_masters = @current_provider.ifa_org_option.ifa_org_option_act_masters.for_master(master) rescue nil
      remove_masters.each do|m|
        m.destroy
      end
    end
    render :partial => "manage_options_ifa_masters"
  end

  def edit_options
    if @current_organization.ifa_org_option
      school_start_valid = true
      school_start = DateTime.parse(params[:start_date]).strftime("%Y-%m-%d") rescue school_start_valid = false
      @current_organization.ifa_org_option.begin_school_year = school_start if school_start_valid
      #
      # Temp Fix for set school start
      #
      @current_organization.ifa_org_option.begin_school_year = "2015-08-30"

      @current_organization.ifa_org_option.days_til_repeat = params[:option][:days_til_repeat].to_i < 0 ? 0: params[:option][:days_til_repeat].to_i
      if @current_organization.ifa_org_option.update_attributes(params[:ifa_org_option])
        flash[:notice] = "Options Updated Successfully"
      else
        flash[:error] = @current_organization.ifa_org_option.errors.full_messages.to_sentence
      end
    end
    redirect_to app_maintenance_ifa_path(:organization_id => @current_organization)
  end

  def classroom_select
    prep_classrooms
    get_classroom
    render :partial =>  "manage_demos", :locals=>{}
  end

  def student_select
    prep_classrooms
    get_classroom
    get_student
    get_period
    render :partial =>  "manage_demos", :locals=>{}
  end

  def edit_dashboard
    get_classroom
    get_student
    get_period
    get_dashboard
    get_class_org_dashboards(@current_subject, @current_period)
    demo_dash_hashes(@current_dashboard, @current_subject, @current_standard)
    if @current_dashboard.nil?
      @current_dashboard = IfaDashboard.new
      @function = 'Create'
    else
      @function = 'Update'
    end
  end

  def update_dashboard
    get_classroom
    get_student
    get_period
    get_dashboard
    if @current_dashboard.nil?
      create_user_dashboard
    else
      adjust_user_dashboard
    end
    if !@current_dashboard.nil?
      dashboard_deltas(@current_dashboard, @current_subject, @current_standard)
      adjust_dashboard(@current_classroom,  @current_subject, @current_period)
      adjust_dashboard(@current_classroom.organization,  @current_subject, @current_period)
      @function = 'Update'
    else
      @current_dashboard = IfaDashboard.new
      @function = 'Create'
    end
    get_class_org_dashboards(@current_subject, @current_dashboard.nil? ? @current_period: @current_dashboard.period_end)
    demo_dash_hashes(@current_dashboard, @current_subject, @current_standard)
    render 'edit_dashboard'
  end


  def tool_r
    @tool_r_classroom_total = Classroom.all.size
    @tool_r_classroom_count = 0
    @tool_r_not_enabled_count = 0
    Classroom.all.each do |clsrm|
      if clsrm.organization.app_enabled?(CoopApp.ifa)
        act_subject_id = clsrm.subject_area_act_subject.nil? ? nil : clsrm.subject_area_act_subject.id
        if clsrm.act_subject_id != act_subject_id
          clsrm.update_attributes(:act_subject_id => act_subject_id)
          @tool_r_classroom_count += 1
        end
      else
        clsrm.update_attributes(:act_subject_id => nil)
        @tool_r_not_enabled_count += 1
      end
    end
    @tool_r_summary = 'Tool R SUMMARY'
    render :partial =>  "tool_r", :locals=>{}
  end

  def tool_q
    @tool_q_plan_count = IfaPlan.all.size
    @tool_q_milestone_count = 0
    @tool_q_plan_bad_level_std_count = 0
    @tool_q_plan_bad_strand_std_count = 0
    @tool_q_plan_bad_level_sbj_count = 0
    @tool_q_plan_bad_strand_sbj_count = 0
    @tool_q_destroyable_milestone_count = 0
    @tool_q_destroyed_milestone_count = 0
    IfaPlan.all.each do |plan|
      @tool_q_milestone_count += plan.milestones.size
      plan.milestones.each do |milestone|
        destroy_it = false
        if (plan.act_subject != milestone.range_subject)
          @tool_q_plan_bad_level_sbj_count += 1
          destroy_it = true
        end
        if (plan.act_subject != milestone.strand_subject)
          @tool_q_plan_bad_strand_sbj_count += 1
          destroy_it = true
        end
        if (@current_standard != milestone.range_standard)
          @tool_q_plan_bad_level_std_count += 1
          destroy_it = true
        end
        if (@current_standard != milestone.standard)
          @tool_q_plan_bad_strand_std_count += 1
          destroy_it = true
        end
        @tool_q_destroyable_milestone_count +=  destroy_it ? 1 : 0

        if params[:destroy_them] == 'Yes' && destroy_it
          milestone.destroy
          @tool_q_destroyed_milestone_count += 1
        end
      end
    end
    @tool_q_destroy = true
    @tool_q_summary = 'Tool Q SUMMARY'
    render :partial =>  "tool_q", :locals=>{}
  end

  def tool_p
    @tool_p_user_db_count = {}
    @tool_p_classroom_db_count = {}
    @tool_p_org_db_count = {}
    @tool_p_bad_user_sub_db = {}
    @tool_p_bad_classroom_sub_db = {}
    @tool_p_bad_org_sub_db = {}
    @tool_p_bad_entity_db = {}

    @tool_p_summary = 'Tool P Analysis Complete'
    ActSubject.plannable.each do |subject|
      @tool_p_user_db_count[subject] = 0
      @tool_p_bad_user_sub_db[subject] = 0
      @tool_p_classroom_db_count[subject] = 0
      @tool_p_bad_classroom_sub_db[subject] = 0
      @tool_p_org_db_count[subject] = 0
      @tool_p_bad_org_sub_db[subject] = 0
      @tool_p_bad_entity_db[subject] = 0

      IfaDashboard.for_subject(subject).each do |dashboard|
        @tool_p_user_db_count[subject] += dashboard.entity_class == 'User' ? 1 : 0
        @tool_p_classroom_db_count[subject] += dashboard.entity_class == 'Classroom' ? 1 : 0
        @tool_p_org_db_count[subject] += dashboard.entity_class == 'Organization' ? 1 : 0
        begin_date = dashboard.period_end.beginning_of_month
        end_date = dashboard.period_end
        submissions = dashboard.ifa_dashboardable.act_submissions.for_subject(subject).submission_period(begin_date, end_date).final
        if dashboard.entity_class == 'User'
          @tool_p_bad_user_sub_db[subject] += dashboard.assessments_taken != submissions.size ? 1:0

        elsif dashboard.entity_class == 'Classroom'
          @tool_p_bad_classroom_sub_db[subject] += dashboard.assessments_taken != submissions.size ? 1:0

        elsif dashboard.entity_class == 'Organization'
          @tool_p_bad_org_sub_db[subject] += dashboard.assessments_taken != submissions.size ? 1:0

        else
          @tool_p_bad_entity_db[subject] += 1
        end
      end
    end
    if params[:reconcile_them] == 'No'
      @tool_p_reconcile = true
      @tool_p_summary = 'Tool P RECONCILE PENDING'
    end
    render :partial =>  "tool_p", :locals=>{}
  end

  def tool_o
    @tool_o_initial_db_count = IfaDashboard.all.size
    @tool_o_wrong_fpoints_total = 0
    @tool_o_wrong_cpoints_total = 0
    @tool_o_extra_std_cell = 0
    @tool_o_extra_std_score = 0
    @tool_o_no_std_cell = 0
    @tool_o_wrong_fanswer_total = 0
    @tool_o_wrong_canswer_total = 0
    @tool_o_no_std_cell_deleted = 0
    @tool_o_no_std_score_deleted = 0
    @tool_o_bad_level_cell_deleted = 0
    @tool_o_no_std_db_deleted = 0
    @tool_o_db_score_updated = 0
    @tool_o_db_plannable = 0
    @tool_o_bad_subject_db_deleted = 0
    @tool_o_bad_entity = 0
    @tool_o_summary = 'Tool O Analysis Complete'
    IfaDashboard.all.each do |dashboard|
      @tool_o_bad_entity += dashboard.entity_unkown? ? 1 : 0
      @tool_o_no_std_cell += dashboard.cells_for_standard(@current_standard).empty? ? 1 : 0
      @tool_o_extra_std_cell += (dashboard.cells_for_standard(@current_standard).size != dashboard.ifa_dashboard_cells.size) ? 1 : 0
      @tool_o_extra_std_score += (dashboard.ifa_dashboard_sms_scores.for_standard(@current_standard).size != dashboard.ifa_dashboard_sms_scores.size) ? 1 : 0
      @tool_o_wrong_fpoints_total += dashboard.fin_points != dashboard.total_points ? 1 : 0
      @tool_o_wrong_cpoints_total += dashboard.cal_points != dashboard.total_c_points ? 1 : 0
      @tool_o_wrong_fanswer_total += dashboard.finalized_answers != dashboard.total_answers ? 1 : 0
      @tool_o_wrong_canswer_total += dashboard.calibrated_answers != dashboard.total_c_answers ? 1 : 0
      @tool_o_db_plannable += !ActSubject.plannable.include?(dashboard.act_subject) ? 1 : 0
    end
    if params[:reconcile_them] == 'No'
      @tool_o_reconcile = true
      @tool_o_summary = 'Tool O RECONCILE PENDING'
    end
    render :partial =>  "tool_o", :locals=>{}
  end

  def tool_n
    @tool_n_until_date = Date.today - 3.years
    @tool_n_initial_db_count = IfaDashboard.all.size
    @tool_n_destroy_db_count = IfaDashboard.up_to(@tool_n_until_date).count
    @tool_n_destroy_user_db_count = 0
    @tool_n_destroy_classroom_db_count = 0
    @tool_n_destroy_org_db_count = 0
    @tool_n_summary = 'Tool N Nothing to DESTROY'
    IfaDashboard.up_to(@tool_n_until_date).each do |dashboard|
      @tool_n_destroy_user_db_count += dashboard.entity_class == 'User' ? 1 : 0
      @tool_n_destroy_classroom_db_count += dashboard.entity_class == 'Classroom' ? 1 : 0
      @tool_n_destroy_org_db_count += dashboard.entity_class == 'Organization' ? 1 : 0
      if params[:destroy_them] == 'Yes'
        #dashboard.destroy
        @tool_n_destroy = false
        @tool_n_summary = 'Tool N DESTROY Complete'
      else
        @tool_n_destroy = true
        @tool_n_summary = 'Tool N DESTROY PENDING'
      end
    end
    render :partial =>  "tool_n", :locals=>{}
  end

  def tool_m
    @tool_m_until_date = Date.today - 3.years
    @tool_m_initial_sub_count = ActSubmission.all.size
    @tool_m_destroy_subs_count = ActSubmission.until(@tool_m_until_date).count
    @tool_m_destroy_answers_count = ActSubmission.until(@tool_m_until_date).collect{|s| s.act_answers.size}.sum
    if params[:destroy_them] == 'Yes'
      ActSubmission.until(@tool_m_until_date).destroy_all
      @tool_m_destroy = false
      @tool_m_summary = 'Tool M DESTROY Complete'
    else
      @tool_m_destroy = true
      @tool_m_summary = 'Tool M DESTROY PENDING'
    end
    render :partial =>  "tool_m", :locals=>{}
  end

  def tool_l
    @tool_l_db_count = 0
    @tool_l_classroom_db_count = 0
    @tool_l_inconsistent_count = 0
    @tool_l_db_no_subject_count = 0
    @tool_l_db_no_classroom_count = 0
    IfaDashboard.all.each do |dashboard|
      @tool_l_db_count += 1
      if dashboard.entity_class == 'Classroom'
        @tool_l_classroom_db_count += 1
        if !dashboard.act_subject
          @tool_l_db_no_subject_count += 1
        end
        if !dashboard.ifa_dashboardable
          @tool_l_db_no_classroom_count += 1
        end
        if dashboard.ifa_dashboardable && dashboard.act_subject && dashboard.ifa_dashboardable.act_subject != dashboard.act_subject
          @tool_l_inconsistent_count += 1
        end
      end
    end
    @tool_l_summary = 'Tool L Summary'
    render :partial =>  "tool_l", :locals=>{}
  end

  def tool_k
    @tool_k_summary = 'Tool K Summary'
    if params[:destroy_them] == 'Yes'
      ActAnswer.all.select{|a| a.act_submission.nil? || a.act_question.nil?}.each.destroy
      @tool_k_destroy = false
      @tool_k_s_orphan_answer_count = 0
      @tool_k_q_orphan_answer_count = 0
      @tool_k_answer_count = ActAnswer.all.size
      @tool_k_summary = 'Tool K DESTROY Complete'
    else
      @tool_k_s_orphan_answer_count = ActAnswer.all.select{|a| a.act_submission.nil?}.size
      @tool_k_q_orphan_answer_count = ActAnswer.all.select{|a| a.act_question.nil?}.size
      @tool_k_answer_count = ActAnswer.all.size
      @tool_k_destroy = true
      @tool_k_summary = 'Tool K DESTROY PENDING'
    end
    render :partial =>  "tool_k", :locals=>{}
  end

  def tool_j
    @tool_j_question_count = 0
    @tool_j_orphan_question_count = 0
    @tool_j_orphan_no_answers = 0
    @tool_j_orphan_with_answers = 0
    @tool_j_orphan_questions = []
    ActQuestion.all.each do |question|
      @tool_j_question_count += 1
      if question.act_assessment_act_questions.empty?
        @tool_j_orphan_question_count += 1
        if question.act_answers.empty?
          @tool_j_orphan_no_answers += 1
          #question.destroy
        else
          @tool_j_orphan_with_answers += 1
          @tool_j_orphan_questions << question
        end
      end
    end
    @tool_j_summary = 'Tool J Summary'
    render :partial =>  "tool_j", :locals=>{}
  end

  def tool_i
    @tool_i_dashboard_count = 0
    @tool_i_dashboard_user_nil = 0
    @tool_i_dashboard_classroom_nil = 0
    @tool_i_dashboard_org_nil = 0
    IfaDashboard.all.each do |dashboard|
      @tool_i_dashboard_count += 1
      if dashboard.period_end.nil?
        @tool_i_dashboard_user_nil += dashboard.ifa_dashboardable_type == 'User' ? 1:0
        @tool_i_dashboard_classroom_nil += dashboard.ifa_dashboardable_type == 'Classroom' ? 1:0
        @tool_i_dashboard_org_nil += dashboard.ifa_dashboardable_type == 'Organization' ? 1:0
       # dashboard.destroy
      end
    end
    @tool_i_summary = 'Tool I Summary'
    render :partial =>  "tool_i", :locals=>{}
  end

  def tool_h
    @tool_h_submission_count = 0
    @tool_h_points_equal = 0
    @tool_h_points_not_equal = 0
    @tool_h_choices_equal = 0
    @tool_h_choices_not_equal = 0
    ActSubmission.all.each do |submission|
      @tool_h_submission_count += 1
      if submission.tot_points == submission.total_points
        @tool_h_points_equal += 1
      else
        submission.update_attributes(:tot_points => submission.total_points)
        @tool_h_points_not_equal += 1
      end
      if submission.tot_choices == submission.total_choices
        @tool_h_choices_equal += 1
      else
        submission.update_attributes(:tot_choices => submission.total_choices)
        @tool_h_choices_not_equal += 1
      end
    end
    @tool_h_summary = 'Tool H Summary'
    render :partial =>  "tool_h", :locals=>{}
  end

  def tool_a
    @tool_question_in_asses = ActQuestion.all.select{|q| !q.act_assessments.empty?}
    @tool_questions_multi_level = @tool_question_in_asses.select{|q| q.act_score_ranges.size > 1}
    @tool_questions_multi_strand = @tool_question_in_asses.select{|q| q.act_standards.size > 1}
    @tool_questions_no_level = @tool_question_in_asses.select{|q| q.act_score_ranges.empty?}
    @tool_questions_no_strand = @tool_question_in_asses.select{|q| q.act_standards.empty?}
    @tool_questions_nil_level = @tool_question_in_asses.select{|q| q.mastery_level.nil?}
    @tool_questions_nil_strand = @tool_question_in_asses.select{|q| q.strand.nil?}
    @tool_a_compatible = ActQuestion.all.select{|q| (q.mastery_level && q.strand && (q.mastery_level.standard == q.strand.standard))}
    @tool_a_incompatible = ActQuestion.all.select{|q| (q.mastery_level && q.strand && (q.mastery_level.standard != q.strand.standard))}
    @tool_a_nil_level = ActQuestion.all.select{|q| (q.mastery_level.nil?)}
    @tool_a_nil_strand = ActQuestion.all.select{|q| (q.strand.nil?)}
    @tool_a_nil_level_strand = ActQuestion.all.select{|q| (q.mastery_level.nil? && q.strand.nil?)}
    @tool_a_summary = 'Tool A Summary'
    render :partial =>  "tool_a", :locals=>{}
  end

  def tool_b
    @tool_b_level_nil = 0
    @tool_b_level_updateable = 0
    @tool_b_level_updated = 0
    @tool_b_strand_nil = 0
    @tool_b_strand_updateable = 0
    @tool_b_strand_updated = 0
    @tool_b_compatible_update = 0
    @tool_b_no_level = 0
    @tool_b_no_strand = 0

    ActQuestion.all.each do |q|
      if q.mastery_level.nil?
        @tool_b_level_nil +=1
        if !q.act_score_ranges.empty?
          @tool_b_level_updateable +=1
          lvl_std = q.act_score_ranges.select{|l| l.act_master == @current_standard}.first
          if lvl_std
            q.update_attributes(:act_score_range_id => lvl_std.id)
            @tool_b_level_updated += 1
          end
        end
      end
      if q.strand.nil?
        @tool_b_strand_nil +=1
        if !q.act_standards.empty?
          @tool_b_strand_updateable +=1
          strnd_std = q.act_standards.select{|l| l.act_master == @current_standard}.first
          if strnd_std
            q.update_attributes(:act_standard_id => strnd_std.id)
            @tool_b_strand_updated += 1
          end
        end
      end
      if !strnd_std.nil? && !lvl_std.nil?
        @tool_b_compatible_update += 1
      else
        strnd_std.nil? ? @tool_b_no_strand += 1 : @tool_b_no_level += 1
      end
    end

    @tool_b_summary = 'Tool B Summary'
    render :partial =>  "tool_b", :locals=>{}
  end

  def tool_c
    @tool_c_question_count = ActQuestion.untagged.size
    @tool_c_with_answer = 0
    @tool_c_tot_answer = 0
    @tool_c_with_assessment = 0
    @tool_c_tot_assessment = 0
    @tool_c_with_level = 0
    @tool_c_with_strand = 0

    ActQuestion.untagged.each do |q|
      if !q.act_answers.empty?
        @tool_c_with_answer += 1
        @tool_c_tot_answer += q.act_answers.size
      end
      if !q.act_assessments.empty?
        @tool_c_with_assessment += 1
        @tool_c_tot_assessment += q.act_assessments.size
      end
      @tool_c_with_level += q.mastery_level ? 1 : 0
      @tool_c_with_strand += q.strand ? 1 : 0
      q.destroy
    end
    @tool_c_summary = ' Tool C Summary'
    render :partial =>  "tool_c", :locals=>{}
  end

  def tool_d
    @tool_d_assessment_count = ActAssessment.all.size
    @tool_d_empty_assessment = 0
    @tool_d_recon_assessment = 0

    ActAssessment.all.each do |a|
      if a.act_questions.empty?
        @tool_d_empty_assessment += 1
       # a.destroy
      else
        @tool_d_recon_assessment += 1
        a.reconstitute
      end
    end
    @tool_d_summary = 'Tool D Summary'
    render :partial =>  "tool_d", :locals=>{}
  end


  def tool_e
    @tool_e_assessment_count = ActAssessment.all.size
    @tool_e_assessments_with_dup_q = 0
    @tool_e_dups = []

    ActAssessment.all.each do |a|
      if a.act_questions.size != a.act_questions.uniq.size
        @tool_e_assessments_with_dup_q += 1
        @tool_e_dups << a
      end
    end
    @tool_e_summary = 'Tool E Summary'
    render :partial =>  "tool_e", :locals=>{}
  end

  def tool_f
    @tool_f_classroom_assess_misalign_count = 0
    @tool_f_misaligned_destroys = 0
    @tool_f_classroom_count = 0
    Classroom.all_precision_prep.each do |classroom|
      misalign = false
      classroom.act_assessments.each do |ass|
        if ass.act_subject != classroom.act_subject
          @tool_f_classroom_assess_misalign_count += 1
          misalign = true
          classroom.act_assessment_classrooms.for_assessment(ass).destroy_all
          @tool_f_misaligned_destroys += 1
        end
      end
        @tool_f_classroom_count += misalign ? 1 : 0
    end
    @tool_f_summary = 'Tool F Summary'
    render :partial =>  "tool_f", :locals=>{}
  end

  def tool_g
    @tool_g_submission_count = 0
    @tool_g_submission_nil_standard = 0
    @tool_g_level_count = 0
    @tool_g_no_level_count = 0
    @tool_g_standard_count = 0
    @tool_g_good_standard_count = 0
    @tool_g_failed_std_update = 0
    @tool_g_no_assessment_count = 0
    @tool_g_no_standard_count = 0
    ActSubmission.all.each do |submission|
      @tool_g_submission_count += 1
      if submission.act_master.nil?
        @tool_g_submission_nil_standard += 1
      end
        if submission.act_assessment
          if submission.act_assessment.upper_level
            if submission.act_assessment.upper_level.act_master == @current_standard
              @tool_g_good_standard_count += 1
              if submission.act_assessment.upper_level && submission.act_assessment.lower_level
                # submission.update_attributes(:upper_score_bound => submission.upper_bound_score, :lower_score_bound => submission.lower_bound_score,)
                @tool_g_level_count += 1
              else
                @tool_g_no_level_count += 1
              end
            else
              @tool_g_wrong_standard_count += 1
            end
          end
        else
          # submission.destroy
          @tool_g_no_assessment_count += 1
        end
    end
    @tool_g_bad_assess_count = 0
    if false
    ActAssessment.all.each do |ass|
        if ass.upper_level.act_master != @current_standard
          @tool_g_bad_assess_count += 1
        end
      end
    end
    @tool_g_summary = 'Tool G Summary'
    render :partial =>  "tool_g", :locals=>{}
  end


  private

  def sat_map_input? (params_lower, params_upper)
    params_lower.to_i >= 0 && params_upper.to_i >= 0 &&
    params_lower.to_i <= 800 && params_upper.to_i <= 800  &&
    params_lower.to_i < params_upper.to_i
  end

  def get_sat_map_id(lower, upper)
    sat_map = ActSatMap.get_map(lower, upper)
    if sat_map.nil? && (lower != 0) && (upper != 0)
      map = ActSatMap.new
      map.lower_score = lower
      map.upper_score = upper
      map.range = lower.to_s + '-' + upper.to_s
      map.save
      sat_map = ActSatMap.get_map(lower, upper)
    end
    sat_map
  end

  def strand_params
    params.require(:act_standard).permit(:name, :abbrev, :description, :strand_background, :strand_font, :pos, :is_active)
  end

  def current_standard
    if params[:act_master_id]
      @current_standard = ActMaster.find_by_id(params[:act_master_id])
    else
      @current_standard = @current_provider.master_standard
    end
  end

  def current_subject
    if params[:act_subject_id]
      @current_subject = ActSubject.find_by_id(params[:act_subject_id]) rescue nil
    else
      @current_subject = ActSubject.first
    end
  end

  def standards
    @standards = ActMaster.all
  end

  def strategies
    @strategies = ActStrategy.by_position
  end

  def strands
    @strands = ActStandard.all_for_standard_and_subject(@current_standard, @current_subject)
  end

  def active_strands
    @active_strands = ActStandard.all_for_standard_and_subject(@current_standard, @current_subject).active
  end

  def subjects
    @subjects = ActSubject.all
  end

  def enabled_subjects
    @subjects = ActSubject.all_subjects
  end

  def current_strand
    if !@strands.empty?
      get_strand
      @current_strand = @current_strand.nil? ? @strands.first : @current_strand
    else
      @current_strand = nil
    end
  end

  def current_strand_benchmarks(options={})
    @current_strand_benchmarks = {}
    @current_level_strands = nil
    if options[:level]
      @current_strand_levels = Array.new
      @current_strand_levels << options[:level]
      @current_strand_benchmarks[options[:level]] = ActBench.all_for_level_strand(options[:level], @current_strand)
    else
      @current_strand_levels = @current_standard.mastery_levels(@current_subject)
      @current_standard.mastery_levels(@current_subject).each do |level|
        @current_strand_benchmarks[level] = ActBench.all_for_level_strand(level, @current_strand)
      end
    end
  end

  def current_level_benchmarks
    @current_level_benchmarks = {}
    @current_strand_levels = nil
    @current_level_strands = @current_standard.strands(@current_subject)
    @current_standard.strands(@current_subject).each do |strand|
      @current_level_benchmarks[strand] = ActBench.all_for_level_strand(@current_level, strand)
    end
  end

  def benchmark_dashboard
    @cell_benchmarks = {}
    @bench_dashboard_hdr = {}
    @bench_total = {}
    @bench_types = {}
    @bench_types_hdr = {}
    @bench_sources = {}
    @bench_sources_hdr = {}
    @bench_for_student = {}
    @bench_taggable = {}
    @types = @current_standard.act_bench_types
    @sources = ActMaster.national
    @bench_dashboard_hdr[0] = @types.map{|t| (t.abbrev + ' = ' + t.name.titleize)}.join(',  ')
    @bench_total['all'] = 0
    @bench_total['enabled'] = 0
    @bench_for_student['all'] = 0
    @bench_taggable['all'] = 0
    @active_levels.each do |level|
      @bench_total[level.range] = 0
      @bench_for_student[level.range] = 0
      @bench_taggable[level.range] = 0
    end
    @active_strands.each do |strand|
      @bench_total[strand.abbrev] = 0
      @bench_for_student[strand.abbrev] = 0
      @bench_taggable[strand.abbrev] = 0
      @active_levels.each do |level|
        ls = level.id.to_s + strand.id.to_s
        @cell_benchmarks[ls] = ActBench.all_for_level_strand(level, strand)
        @bench_total[ls] = ActBench.enabled_for_level_strand(level, strand).size
        @bench_total[strand.abbrev] += @bench_total[ls]
        @bench_total[level.range] += @bench_total[ls]
        @bench_total['enabled'] += @bench_total[ls]
        @bench_total['all'] += ActBench.all_for_level_strand(level, strand).size
        @bench_types_hdr[ls] = []
        @bench_types[ls] = []
        @types.each do |b_type|
          @bench_types_hdr[ls] << b_type.abbrev
          @bench_types[ls] << ActBench.enabled_level_strand_type(level, strand, b_type).size
        end
        @bench_sources_hdr[ls] = []
        @bench_sources[ls] = []
        @sources.each do |std|
          @bench_sources_hdr[ls] << std.abbrev
          @bench_sources[ls] << ActBench.all_for_level_strand(level, strand).select{|b| b.source_standard == std}.size
        end
        @bench_for_student[ls] = ActBench.all_for_level_strand(level, strand).student_benchmarks.size
        @bench_for_student[strand.abbrev] += @bench_for_student[ls]
        @bench_for_student[level.range] += @bench_for_student[ls]
        @bench_for_student['all'] += @bench_for_student[ls]
        @bench_taggable[ls] = ActBench.all_for_level_strand(level, strand).teacher_benchmarks.size
        @bench_taggable[strand.abbrev] += @bench_taggable[ls]
        @bench_taggable[level.range] += @bench_taggable[ls]
        @bench_taggable['all'] += @bench_taggable[ls]
      end
    end
  end

  def get_strand
    if params[:act_standard_id]
      @current_strand = ActStandard.find_by_id(params[:act_standard_id]) rescue nil
    else
      @current_strand = nil
    end
  end

  def cell_strand
    if params[:act_standard_id]
      @cell_strand = ActStandard.find_by_id(params[:act_standard_id]) rescue nil
    else
      @cell_strand = nil
    end
  end

  def get_level
    if params[:act_score_range_id]
      @current_level = ActScoreRange.find_by_id(params[:act_score_range_id]) rescue nil
    else
      @current_level = nil
    end
  end
  def cell_level
    if params[:act_score_range_id]
      @cell_level = ActScoreRange.find_by_id(params[:act_score_range_id]) rescue nil
    else
      @cell_level = nil
    end
  end

  def get_strategy
    if params[:act_strategy_id]
      @current_strategy = ActStrategy.find_by_id(params[:act_strategy_id]) rescue nil
    else
      @current_strategy = nil
    end
  end

  def get_classroom
    if params[:classroom_id]
      @current_classroom = Classroom.find_by_id(params[:classroom_id]) rescue nil
    else
      @current_classroom = nil
    end
  end

  def get_student
    if params[:user_id]
      @current_student = User.find_by_id(params[:user_id]) rescue nil
    else
      @current_student = nil
    end
  end

  def get_period
    if params[:period_end]
      @current_period = Date.parse(params[:period_end])
    elsif params[:dashboard] && params[:dashboard]['period(1i)'] && params[:dashboard]['period(2i)']
      @current_period = Date.new(params[:dashboard]['period(1i)'].to_i, params[:dashboard]['period(2i)'].to_i).end_of_month
    else
      @current_period = Date.today
    end
  end

  def get_dashboard
    if !@current_subject.nil? && !@current_period.nil? && !@current_student.nil?
      @current_dashboard = @current_student.ifa_dashboards.for_subject(@current_subject).for_period(@current_period).first rescue nil
    else
      @current_dashboard = nil
    end
  end

  def get_class_org_dashboards(subject, period_end)
    if !subject.nil? && !period_end.nil?
      @current_class_dashboard = @current_classroom.ifa_dashboards.for_subject(subject).for_period(period_end).first rescue nil
      @current_org_dashboard = @current_classroom.organization.ifa_dashboards.for_subject(subject).for_period(period_end).first rescue nil
    else
      @current_class_dashboard = nil
      @current_org_dashboard = nil
    end
  end

  def adjust_dashboard(entity, subject, current_period)
    # temporary while testing
    if entity.ifa_dashboards.for_subject(subject).for_period(current_period).size > 1
     # entity.ifa_dashboards.for_subject(subject).for_period(current_period).destroy_all
    end
    entity_dashboard = entity.ifa_dashboards.for_subject(subject).for_period(current_period).first rescue nil
    if entity_dashboard.nil?
      dashboard = IfaDashboard.new
      add_dashboard_deltas(dashboard)
      dashboard.ifa_dashboardable_id = entity.id
      dashboard.ifa_dashboardable_type = entity.class.to_s
      dashboard.organization_id = @current_dashboard.organization_id
      dashboard.period_end = @current_dashboard.period_end
      dashboard.act_subject_id = @current_dashboard.act_subject_id
      if dashboard.save
        @current_dashboard.ifa_dashboard_cells.each do |cell|
          hash_key = cell.act_score_range.id.to_s + cell.act_standard.id.to_s
          entity_cell = IfaDashboardCell.new
          entity_cell.act_master_id = @current_standard.id
          entity_cell.act_standard_id = cell.act_standard.id
          entity_cell.act_score_range_id = cell.act_score_range.id
          add_dashboard_cell_deltas(entity_cell, hash_key)
          dashboard.ifa_dashboard_cells << entity_cell
        end
        create_new_dashboard_score(dashboard, @current_standard, subject)
      end
    else
      add_dashboard_deltas(entity_dashboard)
      if entity_dashboard.save
        @current_standard.act_score_ranges.active.for_subject(@current_subject).each do |level|
          @current_standard.act_standards.active.for_subject(@current_subject).each do |strand|
            hash_key = level.id.to_s + strand.id.to_s
            if @cell_deltas[hash_key + 'changed']
              if entity_dashboard.cell_for(level, strand).nil?
                entity_cell = IfaDashboardCell.new
                add_dashboard_cell_deltas(entity_cell, hash_key)
                entity_cell.act_master_id = @current_standard.id
                entity_cell.act_standard_id = strand.id
                entity_cell.act_score_range_id = level.id
                entity_dashboard.ifa_dashboard_cells << entity_cell
              else
                entity_cell = entity_dashboard.cell_for(level, strand)
                add_dashboard_cell_deltas(entity_cell, hash_key)
                if entity_cell.finalized_answers == 0
                  entity_cell.destroy
                else
                  entity_cell.save
                end
              end
            end
          end
        end
        create_new_dashboard_score(entity_dashboard, @current_standard, subject)
      end
    end
  end

  def add_dashboard_deltas(db)
    db.assessments_taken += @dashboard_deltas['assessments_taken']
    db.finalized_assessments += @dashboard_deltas['finalized_assessments']
    db.calibrated_assessments += @dashboard_deltas['calibrated_assessments']
    db.finalized_duration += @dashboard_deltas['finalized_duration']
    db.calibrated_duration += @dashboard_deltas['calibrated_duration']
    db.finalized_answers += @dashboard_deltas['finalized_answers']
    db.fin_points += @dashboard_deltas['fin_points']
    db.calibrated_answers += @dashboard_deltas['calibrated_answers']
    db.cal_points += @dashboard_deltas['cal_points']
    db.cal_submission_points += @dashboard_deltas['cal_submission_points']
    db.cal_submission_answers += @dashboard_deltas['cal_submission_answers']
    db.calibrated_duration += @dashboard_deltas['calibrated_duration']
  end

  def add_dashboard_cell_deltas(db_cell, hash_key)
    db_cell.finalized_answers += @cell_deltas[hash_key +'finalized_answers']
    db_cell.calibrated_answers += @cell_deltas[hash_key +'calibrated_answers']
    db_cell.fin_points += @cell_deltas[hash_key +'fin_points']
    db_cell.cal_points += @cell_deltas[hash_key +'cal_points']
  end

  def create_new_dashboard_score(db, standard, subject)
    if !db.sms_score(standard).nil?
      db.sms_score(standard).destroy
    end
    sms_score = IfaDashboardSmsScore.new
    sms_score.act_master_id = standard.id
    sms_score.score_range_min = db.score_boundary_minimum(standard)
    sms_score.score_range_max = db.score_boundary_maximum(standard)
    sms_score.sms_finalized = standard.sms_for_dashboard(db)
    sms_score.sms_calibrated = standard.sms_for_dashboard(db, :calibrated=>true)
    sms_score.baseline_score = db.ifa_dashboardable_type == 'User' ? standard.base_score(db.ifa_dashboardable, subject) : nil
    db.ifa_dashboard_sms_scores << sms_score

  end

  def adjust_user_dashboard
    orig_user_db_cells(@current_dashboard, @current_subject, @current_standard)
    @current_dashboard.assessments_taken = params[:ifa_dashboard][:assessments_taken].to_i
    @current_dashboard.finalized_assessments = @current_dashboard.assessments_taken
    @current_dashboard.calibrated_assessments = @current_dashboard.assessments_taken
    @current_dashboard.finalized_duration = params[:ifa_dashboard][:finalized_duration].to_i
    @current_dashboard.calibrated_duration = @current_dashboard.finalized_duration
    @current_dashboard.finalized_answers = 0
    @current_dashboard.fin_points = 0.0
    @current_dashboard.ifa_dashboard_cells.for_standard(@current_standard).destroy_all
    @current_standard.strands(@current_subject).each do |s|
      @current_standard.mastery_levels(@current_subject).each do |ml|
        hash_key = ml.id.to_s + s.id.to_s
        if params[:answers][hash_key].to_i > 0
          new_cell = IfaDashboardCell.new
          new_cell.act_master_id = @current_standard.id
          new_cell.act_standard_id = s.id
          new_cell.act_score_range_id = ml.id
          new_cell.finalized_answers = params[:answers][hash_key].to_i
          new_cell.calibrated_answers = new_cell.finalized_answers
          new_cell.fin_points = params[:correct][hash_key].to_f
          new_cell.fin_points = (new_cell.fin_points.to_i > new_cell.finalized_answers) ? new_cell.finalized_answers.to_f : new_cell.fin_points
          new_cell.cal_points = new_cell.fin_points
          new_cell.finalized_hover = ''
          new_cell.calibrated_hover = ''
          @current_dashboard.finalized_answers += new_cell.finalized_answers
          @current_dashboard.fin_points += new_cell.fin_points
          @current_dashboard.ifa_dashboard_cells << new_cell
        end
      end
    end
    @current_dashboard.calibrated_answers = @current_dashboard.finalized_answers
    @current_dashboard.cal_points = @current_dashboard.fin_points
    @current_dashboard.cal_submission_points = @current_dashboard.fin_points
    @current_dashboard.cal_submission_answers = @current_dashboard.finalized_answers
    @current_dashboard.calibrated_duration = @current_dashboard.finalized_duration
    if @current_dashboard.save
      flash[:notice] = "Dashboard Updated"
      create_new_dashboard_score(@current_dashboard, @current_standard, @current_subject)
    else
      @current_dashboard = nil
      flash[:error] = "Dashboard Not Updated"
    end
  end

  def create_user_dashboard
    dashboard = IfaDashboard.new
    orig_user_db_cells(dashboard, @current_subject, @current_standard)
    dashboard.ifa_dashboardable_id = @current_student.id
    dashboard.ifa_dashboardable_type = @current_student.class.to_s
    dashboard.organization_id = @current_classroom.organization.id
    dashboard.period_end = @current_period.end_of_month
    dashboard.act_subject_id = @current_subject.id
    dashboard.assessments_taken = params[:ifa_dashboard][:assessments_taken].to_i
    dashboard.finalized_assessments = dashboard.assessments_taken
    dashboard.calibrated_assessments = dashboard.assessments_taken
    dashboard.finalized_duration = params[:ifa_dashboard][:finalized_duration].to_i
    dashboard.calibrated_duration = dashboard.finalized_duration
    dashboard.finalized_answers = 0
    dashboard.fin_points = 0.0
    @current_standard.strands(@current_subject).each do |s|
      @current_standard.mastery_levels(@current_subject).each do |ml|
        hash_key = ml.id.to_s + s.id.to_s
        if params[:answers][hash_key].to_i > 0
          new_cell = IfaDashboardCell.new
          new_cell.act_master_id = @current_standard.id
          new_cell.act_standard_id = s.id
          new_cell.act_score_range_id = ml.id
          new_cell.finalized_answers = params[:answers][hash_key].to_i
          new_cell.calibrated_answers = new_cell.finalized_answers
          new_cell.fin_points = params[:correct][hash_key].to_f
          new_cell.fin_points = (new_cell.fin_points.to_i > new_cell.finalized_answers) ? new_cell.finalized_answers.to_f : new_cell.fin_points
          new_cell.cal_points = new_cell.fin_points
          new_cell.finalized_hover = ''
          new_cell.calibrated_hover = ''
          dashboard.finalized_answers += new_cell.finalized_answers
          dashboard.fin_points += new_cell.fin_points
          dashboard.ifa_dashboard_cells << new_cell
        end
      end
    end
    dashboard.calibrated_answers = dashboard.finalized_answers
    dashboard.cal_points = dashboard.fin_points
    dashboard.cal_submission_points = dashboard.fin_points
    dashboard.cal_submission_answers = dashboard.finalized_answers
    dashboard.calibrated_duration = dashboard.finalized_duration
    if dashboard.save
      @current_dashboard = dashboard
      flash[:notice] = "Dashboard Created"
      create_new_dashboard_score(@current_dashboard, @current_standard, @current_subject)
    else
      @current_dashboard = nil
      flash[:error] = "Dashboard Not Created"
    end
  end

  def sat_map
    @sats = ActSatMap.all.sort_by{|s| s.lower_score}
  end

  def levels
    @levels = ActScoreRange.all_for_standard_and_subject(@current_standard, @current_subject)
  end

  def active_levels
    @active_levels = ActScoreRange.for_standard_and_subject(@current_standard, @current_subject)
  end

  def current_level
    if !@levels.empty?
      get_level
      @current_level = @current_level.nil? ? @levels.first : @current_level
    else
      @current_level = nil
    end
  end

  def prep_classrooms
    @prep_classrooms = @current_subject.nil? ? [] : @current_subject.classrooms.precision_prep_provider(@current_organization)
  end

  def current_benchmark
    if params[:act_benchmark_id]
      @current_benchmark = ActBench.find_by_id(params[:act_benchmark_id]) rescue nil
    end
  end

  def set_default_bench_type(benchmark)
    benchmark.act_bench_type_id = @bench_types.empty? ? nil : @bench_types.first.id
  end

  def benchmark_source_standards
    @source_standards = ActMaster.national - [@current_standard]
    if !@benchmark_standard.nil?
      @source_levels = @benchmark_standard.mastery_levels(@current_subject).sort_by{|l| [l.standard.abbrev, l.lower_score]}
      @source_strands = @benchmark_standard.strands(@current_subject).sort_by{|s| [s.standard.abbrev, s.name]}
    else
      @source_levels = []
      @source_strands = []
    end
  end

  def get_source_level_strand_ids
    if params[:act_bench][:source_level_id] == ''
      @source_level_id = @current_benchmark.source_level_id
    elsif params[:act_bench][:source_level_id].to_i > 0
      @source_level_id = params[:act_bench][:source_level_id].to_i
    else
      @source_level_id = nil
    end
    if params[:act_bench][:source_strand_id] ==''
      @source_strand_id = @current_benchmark.source_strand_id
    elsif params[:act_bench][:source_strand_id].to_i > 0
      @source_strand_id = params[:act_bench][:source_strand_id].to_i
    else
      @source_strand_id = nil
    end
  end
end
