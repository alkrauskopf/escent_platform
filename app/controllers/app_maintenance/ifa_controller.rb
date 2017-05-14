class AppMaintenance::IfaController < ApplicationController

  layout "ifa_maint", :except =>[:standard_select]

  before_filter :set_ifa, :except=>[]
  before_filter :current_org_current_app_provider?, :except=>[]
  before_filter :current_user_app_superuser?, :except => []
  before_filter :clear_notification, :except => []
  before_filter :current_standard, :except => []
  before_filter :current_subject, :except => []
  before_filter :subjects, :except => []

  def index
    strands
    current_strand
    levels
    current_level
  end

  def standard_select
    strands
    current_strand
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
