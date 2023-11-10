require 'csv'

# Function to read CSV file and return a hash
def read_csv(file)
  CSV.read(file, headers: true).map(&:to_h)
end

# Function to write a hash to CSV file
def write_csv(file, data)
  CSV.open(file, 'w', write_headers: true, headers: data.first.keys) do |csv|
    data.each { |row| csv << row }
  end
end

# Function to find the second lowest cost silver plan for each ZIP code
def calculate_slcsp(plans, zips)
  slcsp_data = []
  silver_plans = plans.filter {|plan| plan['metal_level'] == 'Silver'}
  zips.each do |zip|
    zip_code = zip['zipcode']
    rate_area = zip['rate_area']
    matching_plans = silver_plans.select { |plan| plan['rate_area'] == rate_area }
    if matching_plans.length >= 2
      slcsp_rate = matching_plans.map { |plan| plan['rate'].to_f }.uniq.sort[1]
      slcsp_data << { 'zipcode' => zip_code, 'rate' => format('%.2f', slcsp_rate) }
    else
      slcsp_data << { 'zipcode' => zip_code, 'rate' => nil }
    end
  end
  slcsp_data
end

# Main program
if ARGV.length != 3
  puts 'Usage: ruby slcsp_calculator.rb plans.csv zips.csv slcsp.csv'
  exit
end

plans_file, zips_file, slcsp_file = ARGV

# Read data from CSV files
plans = read_csv(plans_file)
zips = read_csv(zips_file)

# Calculate SLCSP rates
slcsp_data = calculate_slcsp(plans, zips)
puts slcsp_data
# Write the result to the output CSV file
write_csv(slcsp_file, slcsp_data)

puts 'SLCSP calculation completed. Check the output in slcsp.csv.'
