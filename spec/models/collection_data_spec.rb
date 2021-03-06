require 'rails_helper'

RSpec.describe Collection, type: :model do

  # ActiveRecord::Base.logger = Logger.new(STDOUT) if defined?(ActiveRecord::Base)

  # Tests new_collection
  def example_collection name="Stripwell"
    c = Collection.new_collection(name)
    c.save
    raise "Got save errors: #{c.errors.full_messages}" if c.errors.any?
    c
  end

  test_sample = Sample.last

  context 'data' do

    it "gets the right data association matrix" do

      c = example_collection
      c.set 0, 0, Sample.last
      c.set 0, 3, Sample.last      
      c.part(0,0).associate "x", 1.0
      c.part(0,3).associate "y", "hello world"

      m = c.data_matrix "x"
      raise "did not find association x" unless m[0][0].key == "x" && m[0][0].value == 1.0

      m = c.data_matrix "y"      
      raise "did not find association y" unless m[0][3].key == "y" && m[0][3].value == "hello world"

      m = c.data_matrix "z"   
      raise "did not gracefully deal with lack of data association" if m[0][0] != nil
      raise "did not gracefully deal with lack of part" if m[0][1] != nil

    end   

    it "can set data associations of parts" do

      c = example_collection
      c.set_data_matrix "x", [ [ 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2 ] ]
      c.set_data_matrix "y", [ [ "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L" ] ]

      raise "did not set matrix" unless c.get_part_data("x",0,11) == 1.2 && c.get_part_data("y",0,0) == "A"

      c.set_part_data "y", 0, 5, "f"
      raise "did not set specific element" unless c.get_part_data("y",0,5) == "f"

      c.drop_data_matrix "x"
      c.drop_data_matrix "y"

      d = example_collection "96 qPCR collection"      
      d.set_data_matrix "z", [ [ 100, 200 ], [ 400, 500 ] ], offset: [4, 3]

      raise "did not set data matrix with offset" unless d.data_matrix("z")[5][4].value == 500

    end

    it "makes an empty data matrix" do

      d = example_collection "96 qPCR collection" 
      d.new_data_matrix "x"
      m = d.data_matrix "x"
      nz = m.collect { |row| row.collect { |da| da.value } }.flatten.select { |x| x != 0.0 }
      raise "did not make empty data matrix" unless nz.empty?

      d.drop_data_matrix "x"
      m = d.data_matrix "x"
      nn = m.collect { |row| row.collect { |da| da } }.flatten.compact
      raise "did not drop data matrix" unless nn.empty?

    end

  end

end