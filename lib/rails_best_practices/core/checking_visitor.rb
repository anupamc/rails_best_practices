# encoding: utf-8
module RailsBestPractices
  module Core
    # CheckingVisitor is a visitor class.
    #
    # it remembers all the checks for prepare and review processes according to interesting_prepare_nodes and interesting_review_nodes,
    # then recursively iterate all sexp nodes,
    #
    # for prepare process
    # if the node_type and the node filename match the interesting_prepare_nodes and interesting_prepare_files,
    # then run the prepare for that node.
    #
    # for review process
    # if the node_type and the node filename match the interesting_review_nodes and interesting_review_files,
    # then run the reivew for that node.
    class CheckingVisitor
      # remember all the checks for prepare and review processes according to interesting_prepare_nodes and interesting_review_nodes,
      def initialize(checks)
        [:prepare, :review].each do |process|
          instance_variable_set("@#{process}_checks", {})                  # @review_checks = {}
          checks.each do |check|                                           # checks.each do |check|
            check.send("interesting_#{process}_nodes").each do |node|      # check.interesting_review_nodes.each do |node|
              instance_variable_get("@#{process}_checks")[node] ||= []     #   @review_checks[node] ||= []
              instance_variable_get("@#{process}_checks")[node] << check   #   @review_checks[node] << check
              instance_variable_get("@#{process}_checks")[node].uniq!      #   @review_checks[node].uniq!
            end                                                            # end
          end
        end
      end

      # for prepare process
      # if the node_type and the node filename match the interesting_prepare_nodes and interesting_prepare_files,
      # then run the prepare for that node.
      #
      # for review process
      # if the node_type and the node filename match the interesting_review_nodes and interesting_review_files,
      # then run the reivew for that node.
      [:prepare, :review].each do |process|
        class_eval <<-EOS
          def #{process}(node)                                         # def review(node)
            checks = @#{process}_checks[node.node_type]                #   checks = @review_checks[node.node_type]
            if checks                                                  #   if checks
              checks.each { |check|                                    #     checks.each { |check|
                if node.file =~ check.interesting_#{process}_files     #      if node.file =~ check.interesting_review_files
                  check.#{process}_node_start(node)                    #         check.review_node_start(node)
                end                                                    #       end
              }                                                        #     }
            end                                                        #   end
            node.children.each {|sexp| sexp.#{process}(self)}          #   node.children.each {|sexp| sexp.review(self)}
            if checks                                                  #   if checks
              checks.each { |check|                                    #     checks.each { |check|
                if node.file =~ check.interesting_#{process}_files     #       if node.file =~ check.interesting_review_files
                  check.#{process}_node_end(node)                      #         check.review_node_end(node)
                end                                                    #       end
              }                                                        #     }
            end                                                        #   end
          end                                                          # end
        EOS
      end
    end
  end
end
