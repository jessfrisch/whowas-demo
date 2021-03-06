module Whowas
  class Clearpass
    # All required public methods are contained in the Middleware package.  It 
    # initializes the search method, calls search on the adapter with the 
    # provided input, and returns the output to the next search method or the 
    # caller.
    #
    # The Searchable modules (Validatable, Formattable, and Parsable) are
    # technically optional but in practice necessary to ensure usable input and
    # outputs.
    include Whowas::Middleware
    include Whowas::Searchable
      
    ## ADAPTER
    # You MUST set this to the name of a bundled or custom adapter class.
    @@adapter = Whowas::Splunk
    
    private
    
    ## Validatable
    # Optional but useful to prevent making unnecessary API calls when given
    # invalid input.
    
    # Defines required elements of the input hash.
    # This should be an array containing the required inputs as symbols.
    def required_inputs
      [:mac, :timestamp]
    end
    
    # Validates the values of required inputs.
    # This should be a hash containing the required input as key, and a lambda 
    # taking input and returning a boolean as value.
    def input_formats
      {
        mac: lambda { |input| (input =~ /^([0-9A-F]{2}[:-]{0,1}){5}[0-9A-F]{2}$/i) && true rescue false },
        timestamp: lambda { |input| DateTime.parse(input) && true rescue false }
      }      
    end
    
    ## Formattable
    
    # Search method-wide transformations to the input.  For example, if all 
    # mac addresses given as input to this search method should use colons as 
    # separators, perform that transformation here.
    # 
    # Adapter-wide transformations to the input can be made in the adapter 
    # format method.
    def format_input(input)
      input[:query] = "#{input[:mac].tr(':','')} clearpass index=main | head 1"
      input[:offset] = -3600 * 24 * 7
      input
    end
    
    ## Parsable
    
    # Extract pieces of the results string from the adapter using regex to form the 
    # input hash for the next search method or the final result.
    def output_formats
      {
        username: /RADIUS.Acct-Username=\K\w*/
      }
    end    
  end
end