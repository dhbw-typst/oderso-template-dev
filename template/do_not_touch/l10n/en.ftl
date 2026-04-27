### General terms
at-the-institution = at the { $institution } { $city }
weeks = { $count } {
    $count ->
        [one] Week
       *[other] Weeks
}

submission-date = Submission Date
processing-duration = Processing Period
course = Course
training-company = Training Company
department = Department
supervisor-at-training-company = Supervisor at Training Company

statutory-declaration = Statutory Declaration

place-of-signature = Place
date-of-signature = Date
signature = Signature

confidentiality-agreement = Confidentiality Agreement

tool = Tool
usage-description = Usage Description

### Base template
by = by
abstract = Abstract

# lists headers
list-of-notes = List of Notes
table-of-contents = Table of Contents
list-of-abbreviations = List of Abbreviations
list-of-figures = List of Figures
list-of-tables = List of Tables
list-of-code = List of Code
list-of-bibliography = List of Bibliography

# appendix
appendix = Appendix
list-of-appendices = List of Appendices


### DHBW
dhbw-long = Baden-Württemberg Cooperative State University
ka = Karlsruhe
ma = Mannheim
as-part-of-examination-dhbw = as part of the examination for
in-field-of-study = in { $study }
matriculation-number = Matriculation Number
supervisor-at-university = Supervisor at University
course-director = Course Director

statutory-declaration-note-dhbw = { $author-count ->
    [one] I hereby declare that I have written this work independently and have not used any sources or aids other than those specified, and that this work has not been submitted for any other examination with the same or comparable content and has not been published to date.
   *[other] We hereby declare that we have written this work independently and have not used any sources or aids other than those specified, and that this work has not been submitted for any other examination with the same or comparable content and has not been published to date.
}
statutory-declaration-note-dhbw-printed = { $author-count ->
    [one] Furthermore, I declare that the submitted electronic version is identical to the printed version.
   *[other] Furthermore, we declare that the submitted electronic version is identical to the printed version.
}

statutory-declaration-note-dhbw-old = { $author-count ->
    [one] I hereby declare that I have written my { $type } on the topic: "{ $title }" independently and have not used any sources or aids other than those specified.
   *[other] We hereby declare that we have written our { $type } on the topic: "{ $title }" independently and have not used any sources or aids other than those specified.
}

statutory-declaration-note-dhbw-old-printed = { $author-count ->
    [one] Furthermore, I declare that the submitted electronic version is identical to the printed version.
   *[other] Furthermore, we declare that the submitted electronic version is identical to the printed version.
}

confidentiality-agreement-note-dhbw = The contents of this work may not be made accessible, in whole or in part, to persons outside the examination process and the evaluation procedure, unless otherwise authorized by the Dual Partner.
ai-acknowledgement-heading-dhbw = AI Acknowledgement

### IHK
as-part-of-examination-ihk = as part of the
in-the-training-occupation = in the training occupation
examinee-number = Examinee Number
confidentiality-agreement-note-ihk = The contents of this work may not be made accessible, in whole or in part, to persons outside the examination process and the evaluation procedure, unless otherwise authorized by the Training Company.