include ActionController
include ActiveRecord

module SpawnHelper
  COMPLETE = "Complete"
  
  def background()               
    # thread for deadline emails
    spawn do        
      while true do        
        puts "~~~~~~~~~~Spawn Running, time.now is #{Time.now}\n"
        logger.info "Thread running, time #{Time.now}.\n"
        
        #code for sending mails to reviewers.
        #This module here sends mails to reviewers indicating they have been assigned to review.
        #From ResponseMap table we get Reviewer and Reviewee information for each assignment.Using this information we send out mails
        #to reviewers indicating review is pending and needs to be completed.Once mail is sent we set a flag in database indicating 
        #mail has been sent to reviewer , this ensures we don't send duplicate review mails to reviewers. 
        allAssign = Assignment.find(:all)
        for assign in allAssign
          #Get the mapping information <Reviewer, Reviewee> for each assignment.
          allReviewers = ResponseMap.find(:all, :conditions => ["reviewed_object_id =?", assign.id])
          for reviewer in allReviewers
            if (reviewer.notification_not_sent == true)
              user_id = Participant.find(reviewer.reviewer_id).user_id    
              userdetails = User.find(user_id)    
              assign_name = assign.name
              subject = "You have been assigned to review the assignment"
              body = "Hi #{userdetails.fullname}, You have been assigned to review the following assignment :#{assign_name}.\n For more details you can log onto the expertiza and check the details ."    
              # Setting the flag indicating we have sent a mail to reviewer.
              reviewer.setFlag
              #sending mail to indicate review is pending.
              general_email(userdetails.fullname, userdetails.email, subject, body)
            end
          end
        end      
         
        
     
        #code for sending mail, when user moves from waitlist to confirmed slot .
        #we does this using the 2 attributes of the the singedup user table 
        #1)is_waitlisted: is_waitlisted column tracks the current signup status for the topic.
        #2)was_waitlisted: was_waitlisted tracks the initial state of singup status.
        #Eg: when user signup for a topic and he is in waitlist both is_waitlisted and was_waitlisted will be equal to '1'.
        #once the user moves to conformed slot from waitlist , we will have 1)is_waitlisted = 0 2)was_waitlisted = 1
        #We check for this above condition before sending out mail.
        #once we send the mail , we change was_waitlist = 0 so we don't send duplicate mails and flood users inbox. 
        signUpTable = SignedUpUser.find(:all)
        for eachEntry in signUpTable 
          #check for waitlist moved to conformed slot condition.
          if((eachEntry.was_waitlisted  == true) && (eachEntry.is_waitlisted == false) ) 
            topicName = SignUpTopic.find(eachEntry.topic_id).topic_name;	
            body = "You have been moved out of waiting list for the following topic #{topicName} ,\nfor more details login to expertiza and view the details\n";
            subject = "Moved out of waiting list \n";
            userdetails = User.find(eachEntry.creator_id);
            #set the flag so we don't set duplicate mails to user.    
            eachEntry.setFlag
            #send a mail to user indicating user of conformed slot.
            general_email(userdetails.fullname, userdetails.email, subject,body)
          end
        end
         
        # find all assignments in database                
        #allAssign = Assignment.find(:all)
        #query to pick only those assignments that were created in the last 2 weeks - to avoid picking all assignments
        allAssign = Assignment.find(:all, :conditions => ["created_at >= ? AND created_at <= ?", Time.now - 1209600, Time.now]) 
        for assign in allAssign
          #puts "~~~~~~~~~~assignment name #{assign.name}, id #{assign.id}"
          #puts "~~~~~~~~~~Enter assignment #{assign.name}, time.now is #{Time.now}\n and assign.created_at #{assign.created_at} and diff #{(Time.now - 14400) - assign.created_at}\n"
          
#          if((((Time.now - 14400) - assign.created_at) <= 3600) && (((Time.now - 14400) - assign.created_at) >= 0))#if any assignment was created in the last 1hr
#            # get all participants
#                #puts "looking for participants"
#            allParticipants = Participant.find(:all, :conditions => ["parent_id = ?", assign.id])      
#                #puts "~~~~~~~~~~Participants found"
#            for participant in allParticipants
#                userInfo = User.find(participant.user_id)
#                # get users full name
#                fullname = userInfo.fullname    
#                #puts "~~~~~~~~~~Participant name: #{fullname}\n"
#                
#                # get users email address
#                email    = userInfo.email      
#                #puts "~~~~~~~~~~Email: #{email}\n"
#                
#                # get name of assignment
#                assign_name = assign.name
#                #puts "~~~~~~~~~~Assignment name: #{assign_name}\n"                                
#                
#                email_start(fullname, email, assign_name)
#            end 
#         end #end for the 'if' condition

          #puts "Before get_current_due_date()\n"
          #due_date = assign.find_current_stage()#get_current_due_date()
          #puts "~~~~~~~~~~Assignment: #{assign.name}, Due date: #{due_date.due_at}, Time now: #{Time.now}\n"
          #puts "~~~~~~~~~~Current Stage: #{DeadlineType.find(due_date.deadline_type_id).name}\n"
          
          #fetching all due dates for the current assignment
          due_dates = DueDate.find(:all, 
                 :conditions => ["assignment_id = ?", assign.id])
          #puts "~~~~~~~~~~~~~~~~~~~~~due dates size #{due_dates.size} and due_at #{due_dates[0].due_at} and date.due_at - Time.now is #{due_dates[0].due_at - (Time.now-14400)}\n"
          
          if(due_dates.size > 0)#making sure that the assignmefnt does have due dates
            #the above query picks all deadlines for an asisgnment and we check for each and based on the assignment type we perform specific checks and then send email reminders
            for date in due_dates 
              puts "~~~~~~~~~~Date is: #{date.due_at} and date.due_at - Time.now is: #{date.due_at - Time.now} and flag is #{date.flag}\n"
              if((date.due_at - Time.now) <= date.threshold * 3600 && (date.due_at - Time.now) > 0 && date.flag == false)#send reminder
                #puts "~~~~~~~~~~Deadline type is: #{date.deadline_type_id} threshold is: #{date.threshold}\n"
                deadlinetype = date.deadline_type_id
                if deadlinetype == 1 #1 is submission
                  submission_reminder(assign, date)
                  #puts "~~~~~~~~~~back here!"
                end
                if deadlinetype == 2 #2 is review
                  review_reminder(assign, date)
                end
                if deadlinetype == 5 #5 is for metareview
                  metareview_reminder(assign, date)
                end
                #puts "~~~~~~~~~~~~~setting flag"
                date.setFlag
              end
            end #end of for loop
          end #end of the if condition
          #MUST SET A FLAG TO INDICATE THAT REMINDERS HAVE BEEN SENT TO A PARTICIPANT OF AN ASSIGNMENT FOR A SPECIFIC ASSIGNMENT TYPE
          #ELSE THEY WILL GET SPAMMED WITH MESSAGES EVERY HOUR
        end #end 'for' loop for all assignmnets
        logger.info "Thread going to sleep, time #{Time.now}.\n"
        sleep 3600 #sleeps for 1 hour after all reminders have been sent
      end #end of 'while' loop
    end #end of spawn do loop
  end #end of 'def'

  def submission_reminder(assign, due_date)
    allParticipants = Participant.find(:all, :conditions => ["parent_id = ?", assign.id])
    emails = Array.new
    logger.info "Inside submission_reminder for assignment #{assign.name}"
    for participant in allParticipants 
      userInfo = User.find(participant.user_id)                
      email = userInfo.email.to_s     
      #puts "~~~~~~~~~~Email: #{email}\n"                  
      assign_name = assign.name        
      #puts "~~~~~~~~~~Assignment name: #{assign_name}\n"                                  
      assign_type = DeadlineType.find(due_date.deadline_type_id).name
      #puts "~~~~~~~~~~Assignment stage: #{assign_type}\n"      
      #puts "~~~~~~~~~~Sending submission_reminder if no submissions found ... submitted at nil #{(participant.submitted_at == nil)} .. hyperlink nil #{participant.submitted_hyperlink == nil} hyperlink empty #{participant.submitted_hyperlink != ""}\n"
      if(participant.submitted_at == nil && (participant.submitted_hyperlink == nil || participant.submitted_hyperlink == ""))#if(participant.has_submissions == false)
        emails << email
      end
    end#end of for loop
    #puts "~~~~~~~~~~Emails: #{emails.length} addresses, #{assign_name}, #{due_date.due_at}, #{assign_type}\n"
    email_remind(emails, assign_name, due_date, assign_type)
    logger.info "Sent submission reminders for assignment #{assign.name}"
  end

  def review_reminder(assign, due_date)
    allParticipants = Participant.find(:all, :conditions => ["parent_id = ?", assign.id])      
    emails = Array.new
    logger.info "Inside review_reminder for assignment #{assign.name}"
    for participant in allParticipants                
      email = User.find(participant.user_id).email     
      #puts "~~~~~~~~~~Email: #{email}\n"                  
      assign_name = assign.name        
      #puts "~~~~~~~~~~Assignment name: #{assign_name}\n"                                  
      assign_type = DeadlineType.find(due_date.deadline_type_id).name
      #puts "~~~~~~~~~~Assignment stage: #{assign_type}\n"      
      #check if the participant/reviewer has reviewed the latest version of the resubmitted file, else send him a reminder
      allresponsemaps = ResponseMap.find(:all, :conditions => ["reviewer_id = ? AND type = 'ParticipantReviewResponseMap' AND reviewed_object_id = ?", participant.id, assign.id])
      #puts" ~~~~~number of response maps #{allresponsemaps.size}\n"
      if(allresponsemaps.size > 0)
        for eachresponsemap in allresponsemaps
            allresponses = Response.find(:all, :conditions => ["map_id = ?", eachresponsemap.id])
            #puts" ~~~~~number of responses #{allresponses.size}\n"
            resubmission_times = ResubmissionTime.find(:all, :conditions => ["participant_id = ?", eachresponsemap.reviewee_id], :order => "resubmitted_at DESC")           
            #puts" ~~~~~resubmission times: #{resubmission_times.size}\n"
            if(allresponses.size > 0 && resubmission_times.size > 0)#meaning the reviewer has submitted a response for that map_id  
              if(allresponses[0].updated_at < resubmission_times[0].resubmitted_at) #participant/reviewer has reviewed an older version
                  emails << email
              end
            elsif(allresponses.size == 0) #where the reviewee has submitted and reviewer has provided no response
              if(resubmission_times.size > 0)
                emails << email
              else #if the reviewee has made some sort of submission
                reviewee = Participant.find(:all, :conditions => ["id = ?", eachresponsemap.reviewee_id])
                #puts "~~~~~~~~~~Sending review_reminder if no responses found ... submitted at nil #{(reviewee[0].submitted_at == nil)} .. hyperlink nil #{reviewee[0].submitted_hyperlink == nil} hyperlink empty #{reviewee[0].submitted_hyperlink == ""}\n"
                if(reviewee[0].submitted_at != nil || (reviewee[0].submitted_hyperlink != nil && reviewee[0].submitted_hyperlink != ""))
                  #puts "~~~~~~~~~~Email: #{email}\n"   
                  emails << email
                end
              end
           end
        end #endof the response maps loop
      end
    end #end of the for loop for all participants of the assignment
    #puts "~~~~~~~~~~Emails: #{emails.length} addresses, #{assign_name}, #{due_date.due_at}, #{assign_type}\n"
    email_remind(emails, assign_name, due_date, assign_type)
    logger.info "Sent review reminders for assignment #{assign.name}"
  end

  def metareview_reminder(assign, due_date)
    allParticipants = Participant.find(:all, :conditions => ["parent_id = ?", assign.id])      
    emails = Array.new
    logger.info "Inside metareview_reminder for assignment #{assign.name}"
    for participant in allParticipants               
      email = User.find(participant.user_id).email      
      #puts "~~~~~~~~~~Email: #{email}\n"                  
      assign_name = assign.name        
      #puts "~~~~~~~~~~Assignment name: #{assign_name}\n"                                  
      assign_type = DeadlineType.find(due_date.deadline_type_id).name
      #puts "~~~~~~~~~~Assignment stage: #{assign_type}\n"      
      #check if the participant/reviewer has completed the meta-review
      #puts "~~~~~~~~~participant id #{participant.id}"
      allresponsemaps = ResponseMap.find(:all, :conditions => ["reviewer_id = ? AND type = 'MetareviewResponseMap'", participant.id])
      if(allresponsemaps.size > 0)
        for eachresponsemap in allresponsemaps
            #checking to see if the response map was for a review in the same assignment
            checkresponsemap = ResponseMap.find(:all, :conditions => ["id = ? AND type = 'ParticipantReviewResponseMap' AND reviewed_object_id = ?", eachresponsemap.reviewed_object_id, assign.id])
            if(checkresponsemap.size > 0)
              allresponses = Response.find(:all, :conditions => ["map_id = ?", eachresponsemap.id])
              if !(allresponses.size > 0)#meaning the reviewer has not submitted a response for that map_id
                emails << email
              end
            end
        end
      end
    end #end of the for loop
    #puts "~~~~~~~~~~Emails: #{emails.length} addresses, #{assign_name}, #{due_date.due_at}, #{assign_type}\n"
    email_remind(emails, assign_name, due_date, assign_type)
    logger.info "Sent metareview reminders for assignment #{assign.name}"
  end

  def email_remind(emails, assign_name, due_date, assign_type)
      #puts "~~~~~~~~~~~~~inside email reminder email #{emails}"
      due_date_string = due_date.due_at.to_s
      subject = "Message regarding #{assign_type} for #{assign_name}"
      if assign_type == "submission"
        body = "This is a reminder to complete #{assign_type} for assignment #{assign_name}. Deadline is #{due_date_string}."
      end
      if assign_type == "review"
        body = "This is a reminder to complete #{assign_type} for assignment #{assign_name}. Deadline is #{due_date_string}."
      end
      if assign_type == "metareview"
        body = "This is a reminder to complete #{assign_type} for assignment #{assign_name}. Deadline is #{due_date_string}." 
      end  
      Mailer.deliver_message(
        {:bcc => emails,
         :subject => subject,
         :body => body
        })         
  end
  
  def email_start(emails, assign_name)      
      subject = "Message regarding new assignment"
      body = "Hi, #{assign_name} has just been created."    
      Mailer.deliver_message(
        {:bcc => emails,
         :subject => subject,
         :body => body
        })        
  end
  #code maninapultion :added general_email function.
  def general_email(fullname, email, subject,body)      
    
    #     puts "Email -> #{email} " 
    #     puts "Subject -> #{subject} " 
    #     puts "reciepients -> #{email} " 
    #     puts "body -> #{body} " 
    Mailer.deliver_message(
    {:recipients => email,
         :subject => subject,
         :body => body
    })        
  end
  #end of general_email function.
end #end of class