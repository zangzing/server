begin

  require 'faker'

  namespace :db do
    desc "Drop DB and fill it with sample test data"
    task :sample => :environment do
      Rake::Task['build:db'].invoke
      SampleDataLoader.new.create_all
    end
  end
rescue LoadError
  namespace :db do
    desc "Faker gem not found db:populate not available"
    task :populate do
      puts "Faker gem not found db:populate not available"
    end
  end
end


def album_name
    case rand( 5 )
      when 0: return Faker::Address.city
      when 1: return Faker::Internet.domain_word.capitalize+' '+Faker::Address.city
      when 2: return Faker::Name.name+'\'s '+event
      when 3: return Faker::Address.city+' '+rand(41)+1970
      when 4: return Faker::Company.catch_phrase
    end
end

def event
  %w(Wedding Party Baptism Reunion Marriage Bar-Mitzvah Funeral Graduation Commencement Premiere Vacation Road-Trip Recital).rand
end

