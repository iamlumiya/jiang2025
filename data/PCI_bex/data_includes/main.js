PennController.ResetPrefix(null); // Shorten command names (keep this line here))

// Optionally present the comprehension question
const askQuestion = (successCallback, failureCallback, waitTime) => (row) => (row.QUESTION=="1" ? [
  newText("statement",row.STATEMENT),
  newText( "answer_correct" , row.CORRECT ),
  newText( "answer_wrong" , row.WRONG ),

  newCanvas("Canvas", 600, 125)
    .center()
    .add(0,0,getText("statement"))
    .settings.css("font-size", "25px")
    .settings.css("font-family", "Arial")
    .add(   0 , 125 , newText("S =") )
    .add( 500 , 125 , newText("L =") )
    .add(  40 , 125 , getText("answer_correct") )
    .add( 540 , 125 , getText("answer_wrong") )
    .print("center at 50vw","middle at 50vh")
  ,
  // Shuffle the position of the answers (Answer keys are S for left and L for right).
  newSelector("answer")
    .add( getText("answer_correct") , getText("answer_wrong") )
    .shuffle()
    .keys("S","L")
    .log()
    .print()
    .once()
    .wait()
    .test.selected( "answer_correct" )
    .success.apply(null, successCallback().concat(
        [getText("answer_correct").css("border-bottom", "5px solid lightCoral")]
    ))
    .failure.apply(null, failureCallback().concat(
        [getText("answer_wrong").css("border-bottom", "5px solid lightCoral")]
    )),

  // Wait for feedback and to display which option was selected
  newTimer("wait", waitTime)
    .start()
    .wait()
] : []);

const askExerciseQuestion = askQuestion(
  () => [newText("<b>Right!</b>").color("green").center().print().settings.css("font-size", "50px")],
  () => [newText("<b>Wrong!</b>").color("red").center().print().settings.css("font-size", "50px")],
  1000
);

const askTrialQuestion = askQuestion(
  () => [getVar("ACCURACY").set(v=>[...v,true])],
  () => [getVar("ACCURACY").set(v=>[...v,false])],
  300
);

// display a primer which indicates a new item
const newPrimer = () => [
  newText('primer','*')
    .css("font-size", "50pt")
    .css("margin-top", "8px")
    .center()
    .print("center at 50vw", "middle at 50vh"),
  newKey(" ").wait(),
  getText('primer').remove(),
];

Header(
    // Store the participant's demographic information
    newVar("AGE").global(),
    newVar("GENDER").global(),
    newVar("NATIVE").global(),
    newVar("DISORDERS").global(),
    newVar("ACCURACY", []).global()
)
 // Add the participant's demographic information to the results
.log( "age"      , getVar("AGE") )
.log( "gender"   , getVar("GENDER") )
.log( "native"   , getVar("NATIVE") )
.log( "disorders", getVar("DISORDERS"));

// Sequence of events
 Sequence("consent_info", "consent1", "setcounter", "participants", "instructions", randomize("exercise"), "start_experiment","experiment",SendResults(), "end")

// Consent form
newTrial("consent_info",
    newText("consent_text", `
        <h2>Consent Form</h2>

        <p>You are being invited to participate in a research study titled "Reproducibility of Psychological Science and Instruction." This study is being done by Dr. Bria Long from UC San Diego and associated graduate students in Experimental Methods course. You were selected to participate in this study because you are an adult in the U.S. and have been a represented population in previous psychology studies.</p>

        <p>The purpose of this study is to better understand how well previously published studies in the psychological field replicate online and with different populations. Your participation in this research should last approximately 5-30 minutes. If you agree to take part in this study, you may be asked to view a set of stimuli, including pictures, sounds, written text, or videos and then giving some responses via key-presses, verbally, or with paper-and-pencil. We may also observe your choices or preferences among an array of stimuli. These stimuli will be taken directly from or closely adapted from studies that already exist in the published psychological literature. Stimuli will include, e.g., pictures of objects and human faces, audio and video clips, short text passages, etc. None of the stimuli will be disturbing, threatening, or offensive. The online and in-person experiments described in this protocol will take no more than 30 minutes. An example game you might play would be to click on an image on the screen that matches a word you hear being said out loud. Your total expected time commitment for this study is between 5-30 minutes, and is specified in the study description.</p>

        <p>Your participation in this study is completely voluntary and you can withdraw at any time. Choosing not to participate or withdrawing will result in no penalty or loss of benefits to which you are entitled. You are free to skip any question that you choose.</p>

        <p>We will not be asking for any personally identifying information, and we will handle responses as confidentially as possible. Your SONA or Prolific IDs will never be tied to your responses on this survey. However, we cannot guarantee the confidentiality of information transmitted over the Internet. To minimize this risk, data containing anything that might be personally identifiable (e.g. Prolific IDs or IP addresses) will be encrypted on transfer and storage and will only be accessible to qualified lab personnel. We will be keeping data collected as part of this experiment indefinitely. This anonymized data (containing neither Prolific IDs nor IP addresses) may be shared with the scientific community or with other participants to be used as stimuli in future studies.</p>

        <p>If you have questions about this project or if you have a research-related problem, you may contact the researcher(s), Dr. Bria Long, brlong@ucsd.edu. If you have any questions concerning your rights as a research subject, you may contact the UC San Diego Office of IRB Administration at irb@ucsd.edu or 858-246-4777.</p>

        <p>By participating in this research you are indicating that you are at least 18 years old, have read this consent form, and agree to participate in this research study. Please keep this consent form for your records.</p>
    `)
        .cssContainer({
            "width": "90%",
            "max-width": "850px",
            "margin": "20px auto"
        })
        .css({
            "text-align": "left",
            "font-size": "18px",
            "line-height": "1.6"
        })
        .print()
    ,
    newText("decline_notice",
        "If you do not agree to participate, please close this page."
    )
        .center()
        .print()
    ,
    newButton("agree",
        "I am at least 18 years old and agree to participate"
    )
        .cssContainer({"margin": "20px"})
        .center()
        .print()
        .log()
        .wait()
);

//Consent1
newTrial("consent1",
    defaultText
        .cssContainer({"margin-top":"1em", "margin-bottom":"1em"})
        .print()
    ,
    newText("<h1><div class='fancy'>Consent Form</div></h1>")
        .center()
    ,
    newText("<b>Have you read and understood the Information Sheet?</b>")
    ,
    newScale("consent_1",   "Yes", "No")
        .radio()
        .log()
        .labelsPosition("right")
        .print()
    ,
        newText("<b>Have you had the opportunity to ask questions about the study?</b>")
    ,
    newScale("consent_2",   "Yes", "No")
        .radio()
        .log()
        .labelsPosition("right")
        .print()
    ,
    newText("<b>Have all your questions been answered satisfactorily (if applicable)?</b>")
    ,
    newScale("consent_3",   "Yes", "No")
        .radio()
        .log()
        .labelsPosition("right")
        .print()
    ,
    newText("<b>Do you understand that you are free to withdraw from the study? (at any time and without giving a reason)</b>")
    ,
    newScale("consent_4",   "Yes", "No")
        .radio()
        .log()
        .labelsPosition("right")
        .print()
    ,
    newText("<b>I give permission for my data from this study to be shared with other researchers provided that my anonymity is completely protected.</b>")
    ,
    newScale("consent_5",   "Yes", "No")
        .radio()
        .log()
        .labelsPosition("right")
        .print()
    ,
    newText("<b>Do you agree to take part in the study?</b>")
    ,
    newScale("consent_6",   "Yes", "No")
        .radio()
        .log()
        .labelsPosition("right")
        .print()
    ,
    newHtml("form", `<div class='fancy'><input name='consent' id='consent' type='checkbox'><label for='consent'>By clicking this checkbox, I indicate that the study has been explained to me to my satisfaction, and I agree to take part. I understand that I am free to withdraw at any time.</label></div>`)
        .cssContainer({"margin":"1em"})
        .print()
    ,
        newFunction( () => $("#consent").change( e=>{
        if (e.target.checked) getButton("go_to_info").enable()._runPromises();
        else getButton("go_to_info").disable()._runPromises();
    }) ).call()
    ,
    newButton("go_to_info", "Participate in the experiment")
        .cssContainer({"margin":"1em"})
        .disable()
        .center()
        .print()
        .wait(
             newFunction('dummy', ()=>true).test.is(true)
            // ID
            .and ( getScale("consent_1").test.selected("Yes")
                 .failure( newText('errorc1', "Please close the browser and cancel your sign-up in the SONA system. Thank you for your participation.").color("red").bold().center().settings.css("font-size", "24px") )
            ).and ( getScale("consent_2").test.selected("Yes")
                 .failure( newText('errorc2', "Please close the browser and cancel your sign-up in the SONA system. Thank you for your participation.").color("red").bold().center().settings.css("font-size", "24px") )
            ).and ( getScale("consent_3").test.selected("Yes")
                 .failure( newText('errorc3', "Please close the browser and cancel your sign-up in the SONA system. Thank you for your participation.").color("red").bold().center().settings.css("font-size", "24px") )   
            ).and ( getScale("consent_4").test.selected("Yes")
                 .failure( newText('errorc4', "Please close the browser and cancel your sign-up in the SONA system. Thank you for your participation.").color("red").bold().center().settings.css("font-size", "24px") )
            ).and ( getScale("consent_5").test.selected("Yes")
                 .failure( newText('errorc5', "Please close the browser and cancel your sign-up in the SONA system. Thank you for your participation.").color("red").bold().center().settings.css("font-size", "24px") )
            ).and ( getScale("consent_6").test.selected("Yes")
                 .failure( newText('errorc6', "Please close the browser and cancel your sign-up in the SONA system. Thank you for your participation.").color("red").bold().center().settings.css("font-size", "24px") ))
            )
);
// Start the next list as soon as the participant agrees to the ethics statement
// This is different from PCIbex's normal behavior, which is to move to the next list once 
// the experiment is completed. In my experiment, multiple participants are likely to start 
// the experiment at the same time, leading to a disproportionate assignment of participants
// to lists.
SetCounter("setcounter");

// Participant's information: questions appear as soon as information is input
newTrial("participants",
    defaultText
        .cssContainer({"margin-top":"1em", "margin-bottom":"1em"})
        .print()
    ,
    newText("participant_info_header", "<div class='fancy'><h2>Please complete this survey.</p></div>")
        .center()
    ,
    // Age
    newText("<b>How old are you?</b><br>(years old)")
    ,
    newTextInput("input_age")
        .length(6)
        .log()
        .print()

    ,
        // Gender
    newText("<b>What is your gender?</b>")
    ,
    newScale("input_gender",   "Male", "Female", "Non-binary", "Prefer not to say")
        .radio()
        .log()
        .labelsPosition("right")
        .print()
        .wait()
    ,
    // English native speaker
    newText("<b>Would you describe English as your only native language?</b><br>(Please select No if you speak more than one native languages.)")
    ,
    newScale("input_native",   "Yes", "No")
        .radio()
        .log()
        .labelsPosition("right")
        .print()
        .wait()
    ,
    // Disorders
    newText("<b>Do you have any neurological or psychiatric diagnoses (including both formal diagnosis and self diagnosis)?</b><br>(Such as autism, schizophrenia, dyslexia, etc.)")
    ,
    newScale("input_disorders",   "Yes", "No")
        .radio()
        .log()
        .labelsPosition("right")
        .print()
        .wait()
    ,
    // Clear error messages if the participant changes the input
    newKey("just for callback", "") 
        .callback( getText("errorage").remove())
    ,
    // Error messages
    defaultText.color("blue").print()
    ,    // Only validate a click when information is input properly
    newButton("go_to_instru", "Continue")
        .cssContainer({"margin-top":"1em", "margin-bottom":"1em"})
        .print()
        // Check for information
        .wait(
             newFunction('dummy', ()=>true).test.is(true)
            // Age
            .and( getTextInput("input_age").test.text(/^\d+$/)
                .failure( newText('errorage', "Please put in your age.").color("red").bold().center().settings.css("font-size", "24px"), 
                          getTextInput("input_age").text(""))
            // Gender
            ).and ( getScale("input_gender").test.selected()
                 .failure( newText('errorgender', "Please select your gender.").color("red").bold().center().settings.css("font-size", "24px") )
            // Native    
                 ).and ( getScale("input_native").test.selected("Yes")
                 .failure( newText('errornative', "I am sorry to tell you that you are not eligible for this study. None of your personal information will be stored. Please close the browser and cancel your sign-up in the SONA system. Thank you for your participation.").color("red").bold().center().settings.css("font-size", "24px") )
            // Disorders
            ).and ( getScale("input_disorders").test.selected("No")
                 .failure( newText('errordisorders', "I am sorry to tell you that you are not eligible for this study. None of your personal information will be stored. Please close the browser and cancel your sign-up in the SONA system. Thank you for your participation.").color("red").bold().center().settings.css("font-size", "24px") ) )               
            )
    ,
    // Store the participant's information
    getVar("AGE") .set( getTextInput("input_age") ),
    getVar("GENDER")   .set( getScale("input_gender") ),
    getVar("NATIVE") .set( getScale("input_native") ),
    getVar("DISORDERS")   .set( getScale("input_disorders") )
);

// Instructions
newTrial("instructions",
    newHtml("instructions_text", "instructions.html")
        .cssContainer({"margin":"1em"})
        .print()
        ,
    newButton("go_to_exercise", "Start the exercise")
        .cssContainer({"margin":"1em"})
        .center()
        .print()
        .wait()
);

// Exercise
Template("exercise.csv", row =>
  newTrial("exercise",
           newPrimer(),
           // Dashed sentence. Segmentation is marked by "*"
           newController("SelfPacedReadingParadigmSentence", {s : row.SENTENCE, splitRegex: /\*/})
           .center()
           .print("center at 50vw", "middle at 50vh")
           .log()
           .wait()
           .remove(),
           askExerciseQuestion(row))
    .log( "item"      , row.ITEM)
    .log( "condition" , row.CONDITION)
);

// Start experiment
newTrial( "start_experiment" ,
    newText("<h2>Now the formal experiment begins.</h2><p>You will not get feedback for your answers.</p>")
        .center()
        .print()
    ,
    newButton("go_to_experiment", "Start the experiment")
        .center()
        .print()
        .wait()
);

// Experimental trial
Template(
    GetTable("experiment_full.csv").setGroupColumn("LIST"),
    row =>
    newTrial( "experiment",
              newPrimer(),
           // Dashed sentence. Segmentation is marked by "*"
           newController("SelfPacedReadingParadigmSentence", {s : row.SENTENCE, splitRegex: /\*/})
           .center()
           .print("center at 50vw", "middle at 50vh")
           .log()
           .wait()
           .remove(),
           askTrialQuestion(row))
    .log( "list"      , row.LIST)
    .log( "trial"     , row.TRIAL)
    .log( "item"      , row.ITEM)
    .log( "condition" , row.CONDITION)
    .log( "type"      , row.TYPE)
);

// Final screen: Debriefing + SONA credit link
newTrial("end",
    newHtml("debrief_text", "debrief.html")
        .cssContainer({"margin": "1em"})
        .print()
    ,
    newText("sona_credit",
        "<p><a href='https://ucsd.sona-systems.com/webstudy_credit.aspx" +
        "?experiment_id=3164" +
        "&credit_token=73126f52876e4379883bd9b692aadd15" +
        "&survey_code=" + encodeURIComponent(GetURLParameter("id")) +
        "'>Click here to receive your SONA credit.</a></p>"
    )
        .center()
        .print()
    ,
    newButton("hold").wait()
)
.setOption("countsForProgressBar", false);