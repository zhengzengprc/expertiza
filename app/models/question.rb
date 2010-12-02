class Array
  def to_h(key_definition)
    result_hash = Hash.new()    
    counter = 0
    key_definition.each do |definition|
      if not self[counter] == nil then
        result_hash[definition] = self[counter].strip      
      end      
      counter = counter + 1
    end    
    return result_hash
  end
end                 
class Question < ActiveRecord::Base
  belongs_to :questionnaire # each question belongs to a specific questionnaire
  belongs_to :review_score  # each review_score pertains to a particular question
  belongs_to :review_of_review_score  # ditto
  has_many :question_advices, :order => 'score' # for each question, there is 

separate advice about each possible score
  has_many :signup_choices # ?? this may reference signup type questionnaires
  
  validates_presence_of :txt # user must define text content for a question
  validates_presence_of :weight # user must specify a weight for a question
  validates_numericality_of :weight # the weight must be numeric
  
  # Class variables
  NUMERIC = 'Numeric' # Display string for NUMERIC questions
  TRUE_FALSE = 'True/False' # Display string for TRUE_FALSE questions
  CHECKBOX = 'Checkbox'
  
  GRADING_TYPES = [[NUMERIC,false],[TRUE_FALSE,true],[CHECKBOX,1]]
  WEIGHTS = [['1',1],['2',2],['3',3],['4',4],['5',5]]
  QUESTION_TYPES = [['CHECKBOX',1],['RADIO',2],['DESCRIPTIVE',3]]
  
  attr_accessor :checked
  attr_accessor :type
  attr_accessor :label
  
  def delete      
    QuestionAdvice.find_all_by_question_id(self.id).each{|advice| advice.destroy}
    self.destroy
  end
    
  def parse
    q_and_a = txt.split(/\{|\}/).collect do |x| x.strip end
    answers = q_and_a[1]
    if answers.nil?
      return nil
    end
    offset = answers.index(/=|~/)
    output = {:question => q_and_a[0], :answers => [], :correct => []}
    count = 0
    while offset
      next_offset = answers.index(/=|~/, offset + 1)
      puts "#{answers[offset]}"
      if answers[offset...offset+1] =~ /=/
        puts 'Correct!'
        output[:correct] << count
      end
      if next_offset
        terminus = next_offset
      else
        terminus = answers.length
      end    
      output[:answers] << answers[offset+1...terminus].strip
      offset = next_offset
      count = count + 1
    end
    output
  end


def before_save
  if self.label.nil?
    self.labels = ""
  else
    q = self.label
    labelT = ""
    q.each { |key, value| labelT += (value.to_s)+"|" }
    self.labels = labelT
   end
end



def after_find
  
  arr = Array.new()
  index1 = Array.new()
  if self.labels ==""
    self.label = nil
  else
    arr = self.labels.split('|')
    index = (1..arr.length).to_a
    for each in index
      index1[each-1] = each.to_s
    end
    #self.label = Hash.new()
    self.label = arr.to_h(index1)
  end
  return
end
end
