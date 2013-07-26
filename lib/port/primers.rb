require 'CSV'
require 'port/user'

def import_primers
  data = []
  i = 0
  CSV.foreach('/Users/ericklavins/Development/bioturk/lib/port/primers.csv',"r") do |row|
    if i < 250
      p = Primer.new
      p.description = row[1]
      p.annealing   = row[2]
      p.overhang    = row[3]
      p.created_at  = Date.parse(row[4])
      p.updated_at  = Date.parse(row[5])
      p.tm          = row[6].to_f
      p.notes       = row[7]
      p.project     = row[8].to_i
      p.owner       = new_user_id(row[9].to_i)
      p.save
    end
    i += 1
  end
  data
end
