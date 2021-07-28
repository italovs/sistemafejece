desc 'transfer the values of actual month table to historic of months'
task change_month: :environment do
  month = Date.today.month
  year = Date.today.year
  if month == 1
    year -= 1
    month = 12
  else
    month -= 1
  end
  posts = ActualMonth.distinct.pluck(:post_id)

  posts.each do |post|
    total_views = 0
    # post_count_uniq_views = ActualMonth.where(post_id: post).count
    ejs = ActualMonth.distinct.pluck(:junior_enterprise_id)
    ejs.each do |ej|
      puts ej
      ej_registers = if ej == 0
                       ActualMonth.where(admin: true, junior_enterprise_id: ej)
                     else
                       ActualMonth.where(junior_enterprise_id: ej, admin: false)
                     end
      ej_registers.each do |register|
        total_views += register.views
      end
      MonthHistory.create(junior_enterprise_id: ej,
                          views: total_views,
                          uniq_views: ej_registers.count,
                          month: month,
                          year: year,
                          post_id: post)
    end
  end
end
