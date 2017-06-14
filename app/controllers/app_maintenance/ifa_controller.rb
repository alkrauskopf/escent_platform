class AppMaintenance::IfaController < AppMaintenance::ApplicationController

  layout "ifa_maint", :except =>[:standard_select, :add_remove_standard_option]

  before_filter :set_ifa, :except=>[]
  before_filter :current_org_current_app_provider?, :except=>[]
  before_filter :current_user_app_superuser?, :except => []
  before_filter :clear_notification, :except => []
  before_filter :current_standard, :except => []
  before_filter :current_subject, :except => []
  before_filter :subjects, :except => []
  before_filter :current_ifa_options
  before_filter :prep_classrooms

  def index
    standards
    strands
    current_strand
    levels
    current_level
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
    strands
    current_strand
    levels
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
    if false
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
    @subject.update_attributes(:name=>params[:name], :is_plannable => (params[:is_plannable] == 'Y' ? true:false))
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

  def level_update
    levels
    current_level
    @current_level.update_attributes(:range=>params[:range], :lower_score => params[:lower_score], :upper_score => params[:upper_score],
                                      :score_background=>params[:score_background], :score_font=>params[:score_font])
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
    # Don't want to make this possible yet.
   # if @current_level.destroy
   #   flash[:notice] = "Level Destroy"
   #   levels
   #   @current_level = @levels.first rescue nil
   # end
    render :partial =>  "edit_level", :locals=>{:level => @current_level}
  end

  def benchmark_refresh
    get_strand
    levels
    render :partial =>  "manage_benchmarks_strand", :locals=>{:strand => @current_strand}
  end

  def benchmark_toggle
    current_benchmark
    @current_benchmark.update_attributes(:is_active=> !@current_benchmark.is_active)
    render :partial =>  "show_benchmark",  :locals=>{:strand => @current_benchmark.strand, :level => @current_benchmark.mastery_level,
                                                     :benchmark => @current_benchmark, :benchmark_id => @current_benchmark.public_id}
  end

  def benchmark_destroy
    current_benchmark
    strand = @current_benchmark.strand
    level = @current_benchmark.mastery_level
    benchmark_id = @current_benchmark.public_id
    if @current_benchmark.destroy
      flash[:notice] = "Benchmark Destroyed"
    end
    render :partial =>  "show_benchmark",  :locals=>{:strand => strand, :level => level, :benchmark => nil, :benchmark_id => benchmark_id}
  end

  def benchmark_add
    get_strand
    get_level
    @bench_types = @current_level.standard.act_bench_types
    @current_benchmark = ActBench.new
    set_default_bench_type(@current_benchmark)
  end

  def benchmark_edit
    get_strand
    get_level
    current_benchmark
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
    if params[:act_bench][:act_benchmark_type_id] != ''
      @current_benchmark.act_bench_type_id = params[:act_bench][:act_benchmark_type_id]
    end
    @current_benchmark.pos = params[:act_bench][:pos]
    if @current_benchmark.save
      flash[:notice] = "Benchmark Updated"
    else
      flash[:error] = @current_benchmark.errors.full_messages.to_sentence
    end
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

  private

  def strand_params
    params.require(:act_standard).permit(:name, :abbrev, :description, :strand_background, :strand_font, :pos, :is_active)
  end

  def current_standard
    if params[:act_master_id]
      @current_standard = ActMaster.find_by_id(params[:act_master_id]) rescue ActMaster.default
    else
      @current_standard = ActMaster.default
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

  def strands
    @strands = ActStandard.all_for_standard_and_subject(@current_standard, @current_subject)
  end

  def subjects
    @subjects = ActSubject.all
  end

  def current_strand
    if !@strands.empty?
      get_strand
      @current_strand = @current_strand.nil? ? @strands.first : @current_strand
    else
      @current_strand = nil
    end
  end

  def get_strand
    if params[:act_standard_id]
      @current_strand = ActStandard.find_by_id(params[:act_standard_id]) rescue nil
    else
      @current_strand = nil
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

  def levels
    @levels = ActScoreRange.all_for_standard_and_subject(@current_standard, @current_subject)
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

  def get_level
    if params[:act_score_range_id]
      @current_level = ActScoreRange.find_by_id(params[:act_score_range_id]) rescue nil
    else
      @current_level = nil
    end
  end

  def current_benchmark
    if params[:act_benchmark_id]
      @current_benchmark = ActBench.find_by_id(params[:act_benchmark_id]) rescue nil
    end
  end

  def set_default_bench_type(benchmark)
    benchmark.act_bench_type_id = @bench_types.empty? ? nil : @bench_types.first.id
  end
end
