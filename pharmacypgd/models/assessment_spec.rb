require 'spec_helper'

describe Assessment do
  it {
    should belong_to :user
    should belong_to :pgd
  }

  it "should have a assessment by PGD scope" do
    @pgd_1 = Factory :pgd

    @assessment_1 = Factory :assessment, :pgd => @pgd_1
    @assessment_2 = Factory :assessment

    Assessment.by_pgd(@pgd_1.id).should include(@assessment_1)
    Assessment.by_pgd(@pgd_1.id).should_not include(@assessment_2)
  end


  describe "should accept answers" do
    before do
      @pgd = Factory :pgd
      @questions = []
      (1..6).each do
        @questions << Factory(:question, :pgd => @pgd)
      end

      @assessment = Factory :assessment, :pgd => @pgd
    end

    it "should validate answers" do
      answer = @assessment.answer({ :question_id => @questions[0].id, :choice => @questions[0].correct_answer_id })
      answer.result.should == true  # correct answer
      answer.response_message.should == @questions[0].correct_answer_text

      @assessment.answer({ :question_id => @questions[0].id, :choice => 'yes' }).result.should == false # attempt to answer same question twice

      answer = @assessment.answer({ :question_id => @questions[1].id, :choice => 'no' })
      answer.result.should == false  # invalid answer
      answer.response_message.should == @questions[1].incorrect_answer_text
      answer.assessment_status.should == @assessment.status
      @assessment.status.should == 'incomplete'
    end

    it "should fail after N invalid answers" do
      answer = nil
      (1..Assessment::MAX_INVALID_ANSWERS).each do |n|
        answer = @assessment.answer({ :question_id => @questions[n].id, :choice => 'no' })
      end
      answer.assessment_status.should == 'failed'
    end

    it "should pass if answers correct" do
      answer = nil
      @questions.each do |q|
        answer = @assessment.answer({:question_id => q.id, :choice => q.correct_answer_id })
      end
      answer.assessment_status.should == @assessment.status
      @assessment.status.should == 'complete'
      @assessment.valid_until.should == Date.today + 6.weeks
      @assessment.completed_at.should == Date.today
    end
  end

  describe ".complete?" do
    before {@assessment = Factory :assessment}
    subject {@assessment.complete?}
    it "should return true if status complete" do
      @assessment.status = 'complete'
      subject.should be_true
    end
    it "should be false otherwise" do
      @assessment.status = 'unknown'
      subject.should be_false
    end
  end
  
  describe ".incomplete?" do
    before {@assessment = Factory :assessment}
    subject {@assessment.incomplete?}
    it "should return true if status is not complete" do
      @assessment.status = 'unknown'
      subject.should be_true
    end
    it "should be false otherwise (status == complete)" do
      @assessment.status = 'complete'
      subject.should be_false
    end
  end

  describe ".failed?" do
    before {@assessment = Factory :assessment}
    subject {@assessment.failed?}
    it "should return true if status failed" do
      @assessment.status = 'failed'
      subject.should be_true
    end
    it "should be false otherwise" do
      @assessment.status = 'unknown'
      subject.should be_false
    end
  end
end
