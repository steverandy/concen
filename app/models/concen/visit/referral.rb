module Concen
  module Visit
    class Referral
      include Mongoid::Document

      store_in self.name.underscore.gsub("/", ".").pluralize

      field :hour, :type => Time
      field :url, :type => String
      field :domain, :type => String
      field :count, :type => Integer, :default => 1

      index :hour, :background => true
      index :url, :background => true
      index :domain, :background => true

      def self.aggregate_count_by_domain(*args)
        options = args.extract_options!

        map = <<-EOF
          function() {
            if (this.domain != null) {
              emit(this.domain, this.count);
            };
          }
        EOF

        reduce = <<-EOF
          function(time, counts) {
            var count = 0;
            for (index in counts) { count += counts[index]; };
            return count;
          }
        EOF

        results = self.collection.map_reduce(map, reduce, :out => {:inline => 1}, :raw => true)["results"]
        results = results.sort {|x,y| y["value"] <=> x["value"]}
        results = results[0..options[:limit]-1] if options[:limit]
        results = results.map do |result|
          [result["_id"], result["value"].to_i]
        end
      end
    end
  end
end
