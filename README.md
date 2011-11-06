Project E214, Cover all student workflows with cucumber tests

Contact:  Edward Anderson (nilbus@nilbus.com)
See https://github.com/expertiza/expertiza/issues/106.

Welcome to our project for our OSS project.

Our main work is in the features files.

The cucumber test plugins is intergrated into the expertiza master branch project, you can open one file in the features/student directory and run it in rubymine.

For the test work you should create some data for test first.

Create a account name:student, with password:password 


attend_survey.feature
Should assign a assignments name "test_team_invites"
 to account student, and the state for the assignment should be completed. So you can see the "Take a survey" link.

change_handle.feature
Should assign a assignments name "test_team_invites"
 to account student, and the state for the assignment should be completed. With the link "Change your handle".

create_a_team.feature
Should assign a assignments name "test_create_team"
 to account student, and the state for the assignment should be completed. With the link "Change your handle".

edit_team_name.feature
Should assign a assignments name "test_Metareview" to account student, and the student already in a team, you can test change the team name.

edit_user_profile.feature
Just run, not need instance.

leave_team.feature
Should assign a assignments name "test_Metareview" to account student, and the student already in a team, so you can test leave.

manage_login_users.feature
Exist the account with name "admin", password "password".

manage_review.feature
Should assign a assignments name "test_Metareview" to account student, it will fail since the review controller not work.

manage_review_for_teammate.feature
Should assign a assignments name "test_Metareview" to account student and add another guy to your team like "admin", it will fail since the review controller not work.

signup_for_topic.feature
Should assign a assignments name "test student signup" to account student, and the admin account assign some topics which test to the student account. 

submit_metareview.feature
Should assign a assignments name "test_Metareview" to account student, and assign a assign an Metareview to the "test_Metareview"  so we can test review.It will fail since the review controller not work.

submit_review.feature
Should assign a assignments name "test_Metareview" to account student, and set the "test_Metareview" to random choose topic to review  so we can test review.It will fail since the review controller not work.

submit_review_for_teammate.feature
Should assign a assignments name "UNC TLT demo" to account student, and add another teamate "admin" to the student team.

submit_work_to_assignment.feature
Should assign a assignments name "test_submit_assigment" to account student, and the state of the assignment should be in submission.

suggest_topic.feature
Should assign a assignments name "test_Metareview" to account student, and use admin account assign this assignment with suggest topic feature.

team_invites.feature
Should assign a assignments name "test_team_invites" to account student, and use another account "admin" send "invite" to student account.

view_resulting_scores.feature
It includes 3 senarios, assign a assignments name "test_Metareview" to account student and have the score in view_resulting_scores.feature which it mention. It will fail since the review controller not work.