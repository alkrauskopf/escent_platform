module ImportExcel
  def self.get_excel(where)
    return if where.blank?
    results = ActiveRecord::Base.connection.select_all(where)
    return if results.blank?
    file_name = "#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}.xls"
    file_path = "#{RAILS_ROOT}/public/selects/"
    FileUtils.mkdir_p(file_path) if !File::exist?(file_path)
    file_dir = file_path + file_name
    workbook = Spreadsheet::Excel.new(file_dir)
    worksheet = workbook.add_worksheet("Select From Result")
    worksheet.write(0 , 0 ,results.first.keys)
    key = 1
    results.each do |row|
      worksheet.write(key , 0 , row.values)
      key = key + 1
    end
    workbook.close
    [file_dir , file_name]
  end
end