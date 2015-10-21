---
layout: docs
title: Setting variables (and doing other things) with questions
short_title: Setting Variables
---

To instruct **docassemble** to store user input in a variable in
response to a question, add one of the following statements to the
`question` block.

## `yesno` or `noyes`

{% highlight yaml %}
---
question: Were you injured?
yesno: user_has_injury
---
{% endhighlight %}

The `yesno` statement causes a question to set a boolean (true/false)
variable when answered.

In the example above, the web app will present "Yes" and "No" buttons
and will set `user_has_injury` to `True` if "Yes" is pressed, and
`False` if "No" is pressed.

The `noyes` statement is just like `yesno`, except that "Yes" means
`False` and "No" means `True`.

{% highlight yaml %}
---
question: Were you not injured?
noyes: user_has_injury
---
{% endhighlight %}

## Multiple-choice `buttons`

{% highlight yaml %}
---
question: Do you understand what I have explained to you?
field: user_understands
buttons:
  - I understand: understands
  - I do not understand: does not understand
  - "I'm not sure": I'm not sure
---
{% endhighlight %}

(Note that in the example above, quotation marks are used because the
apostrophe in "I'm not sure" would otherwise confuse the [YAML]
parser.)

A `question` block with a `buttons` statement will set the variable
identified in `field` to a particular value depending on which of the
buttons the user presses.

The `buttons` statement must always refer to a [YAML] list, so that
**docassemble** knows the order of the buttons.

Each item under `buttons` can either be a [YAML] key-value pair
(written in the form of "- key: value"), where the key is the button
label that the user sees and the value is what the variable identified
in `field` will be set to if the user presses that button.

An item under `buttons` can also be plain text; in that case
**docassemble** uses the text for both the label and the variable
value.  For example, this:

{% highlight yaml %}
---
field: user_gender
question: What is your gender?
buttons:
  - Male
  - Female
---
{% endhighlight %}

is equivalent to:

{% highlight yaml %}
---
field: user_gender
question: What is your gender?
buttons:
  - Male: Male
  - Female: Female
---
{% endhighlight %}

A powerful feature of `buttons` is the ability to use Python code to
generate button choices.  If an item under `buttons` is a key-value
pair in which the key is the word `code`, then **docassemble**
executes the value as Python code, which it expects to return a list.
This code is executed at the time the question is asked, and the code
can include variables from the interview.  **docassemble** will
process the resulting list and create additional buttons for each
item.  To illustrate this, the first example above could alternatively
have been written as:

{% highlight yaml %}
---
field: user_understands_no_attorney_client_relationship
question: >-
  Your use of this system does not mean that you have a lawyer.  Do
  you understand this?
buttons:
  - "I understand": understands
  - code: |
      [{'does not understand':"I do not understand"}, {'unsure':"I'm not sure"}]
---
{% endhighlight %}

Note that the Python code needs to return key-value pairs (Python
dictionaries) where the key is what the variable should be set to and
the value is the button label.  This is different from the [YAML]
syntax.

## `fields`

The `fields` statement is used to present the user with a list of
fields.

{% highlight yaml %}
---
question: Tell me about yourself
fields:
  - Favorite color: user_favorite_color
  - Description of your ideal vacation: user_ideal_vacation
    datatype: area
    required: false
---
{% endhighlight %}

The `fields` must consist of a list in which each list item is one or
more key/value pairs.

There are a number of keys that have a special meaning (and therefore
are not available for use as a label).  If a key is not a special key,
it will be treated as a label, the value of which will refer to a
variable.

The following are the keys that have special meaning:

* `datatype`: affects how the data will be collected, validated and
  stored; see below.
* `required`: the value is either `true` or `false`.  By default, all fields are required.
* `hint`: in text inputs, the value is provided as a [placeholder].
* `help`: the value is explanatory help text that appears when user
  clicks on the label.
* `default`: the value will be set as the default value of the input field
* `choices`: a list of possible options for a multiple choice field.
  Can be a list of key/value pairs (key is what the variable will be
  set to; value is the label seen by the user) or a list of plain text
  items (in which case the label and the variable value are the same).
* `code`: code that generates a list of possible options for a multiple choice field
* `shuffle`: the value is either `true` or `false`.  When used with `code`
  or `choices`, it randomizes the list of choices.
* `note`: the value is [Markdown] text that will appear on the screen;
  useful for providing guidance to the user on how to enter information.
* `html`: like `note`, except raw HTML.
* `script`: raw HTML to be appended to the bottom of the page; usually
  used for Javascript code that interacts with HTML specified in
  `html` entries.

In addition, if you use `no label` as the label for your variable, the
label will be omitted.  On wide screens, the field will fill more of
the width of the screen if the label is set to `no label`.  To keep
the width of the field normal, but have a blank label, use `""` as the
label.

The possible `datatype` values are:

* `text`: a single-line text input box (the default).
* `area`: a multi-line text area
* `date`: a valid date.
* `email`: a valid e-mail address.
* `number`: a valid numeric value.
* `currency`: a valid numeric value; input box shows a currency symbol
  based on locale defined in the [configuration].
* `file`: a single file upload (`DAFile` object).
* `files`: single or multiple file upload (`DAFileList` object).
* `yesno`: checkbox with label, aligned with labeled fields.
* `yesnowide`: checkbox with label, full width of area.
* `checkboxes`: show `choices` list as checkboxes; variable will be a
  dictionary with items set to true or false depending on whether the
  option was checked.  No validation is done to see if the user
  selected at least one, regardless of the value of `required`.
* `radio`: show `choices` list as radio buttons instead of a dropdown
  [select] tag (which is the default).  Variable will be set to the
  value of the choice.

Here is a long example that illustrates many of these features.

Compare this screenshot . . .

![Screenshot of fields]({{ site.baseurl }}/img/fields-example.png)

. . . with this `question` block:

{% highlight yaml %}
---
question: Tell me more about yourself
fields:
  - Description: user_description
    datatype: area
    hint: |
      E.g., you can describe your hair color, eye color, 
      favorite movies, etc.
  - Annual income: user_annual_income
    datatype: currency
  - E-mail address: user_email_address
    datatype: email
  - Been vaccinated: user_vaccinated
    datatype: yesno
  - Seen Mount Rushmore: mount_rushmore_visited
    datatype: yesnowide
  - Belly button type: belly_button_type
    datatype: radio
    choices:
      - Innie
      - Outie
  - html: |
      <p>The date and time is <span id="today_time"></span>.
  - script: |
      <script>
        document.getElementById("today_time").innerHTML = Date();
      </script>
  - Number of friends: number_of_friends
    datatype: radio
    choices:
      - One: 1
      - Two: 2
      - Three: 3
  - Degrees obtained: degrees
    datatype: checkboxes
    choices:
      - High school
      - College
      - Graduate school
  - State you grew up in: home_state
    code: |
      us.states.mapping('abbr', 'name')
  - note: |
      #### Politics

      Tell me about your political views.
  - no label: political views
    default: I have no political views
  - Political preference: political_party
    datatype: radio
    shuffle: true 
    choices:
      - Republican
      - Democrat
      - Independent
---
{% endhighlight %}

By comparing the screenshot to the [YAML] code, you can see how each
of the features works.

## `sets`

{% highlight yaml %}
---
question: We are all done.
sets: user_done
---
{% endhighlight %}

A `sets` line tells **docassemble** that if it is looking for the
value of a particular variable, it should try asking the question in
the question block containing the `sets` statement.

This does not necessarily mean that the variable identified in `sets`
will actually be set.  For example, the question above does not allow
the user to do anything.

When used as an "empty promise" of setting a variable, the `sets`
statement is useful for creating the final screen that the user sees
before exiting the interview.  For example, the interview logic can
cause the "question" above to appear by including a final line of code
such as:

    need(user_done)

The `user_done` variable will never be set to any value, but that is
ok, because you don't want the user to be able to "get past" the final
screen.

## `sets` with special buttons/choices 

The `sets` statement is also used in conjunction with `buttons` in
multiple choice questions where there is no `field` to be set.

{% highlight yaml %}
---
question: We are all done.
sets: user_done
buttons:
  - Exit: exit
  - Restart: restart
---
{% endhighlight %}

The above example allows the user to "exit" the interview (be redirected
to a specific web site that is pre-set in the **docassemble**
[configuration] or "restart" the interview (go back to the beginning).

There are four special button functions:

* `restart`
* `exit`
* `leave`
* `continue`

`restart` resets the user's variable store, except that any parameters
that were originally passed through as URL parameters will be used again.

`exit` means that the user's variable store will be reset and the user
will be redirected to a pre-defined web site.  If the user tries to come
back to the interview again, he will start the interview again, as
though it had never been started.  Original URL parameters will be
lost.

`leave` means that the user will be redirected to a pre-defined web
site, but the user's variable store will be left intact.  This means
that if the user comes back to the interview again, he will pick up
where he left off.

`continue` means that **docassemble** will look for another question
in the interview that might provide the necessary variable.

Instead of using `buttons`, you can use `choices` to get a radio list
instead of a selection of buttons.

{% highlight yaml %}
---
question: We are all done.
sets: user_done
choices:
  - Exit: exit
  - Restart: restart
---
{% endhighlight %}

The functionality is the same.

## buttons/choices that embed `question` and `code` blocks

Multiple choice questions can embed `question` blocks and `code`
blocks.  These questions are just like ordinary questions, except they
can only be asked by way of the questions in which they are embedded.

You embed a question by providing a [YAML] key-value list (a
dictionary) (as opposed to text) as the value of a label in a
`buttons` or `choices` list.

{% highlight yaml %}
---
question: What is your favorite color?
buttons:
  - Red:
      question: Dark red or light red?
      field: favorite_color
      buttons:
        - Dark Red
        - Light Red
  - Green:
      question: Dark green or light green?
      field: favorite_color
      buttons:
        - Dark Green
        - Light Green
---
{% endhighlight %}

While embedding `question` blocks can be useful sometimes, it is
generally not a good idea to structure interviews with a lot of
embedded questions.  You will have more flexibility if your questions
stand on their own.

It is also possible for multiple-choice questions to embed `code`
blocks that execute Python code.  (If you do not know what `code`
blocks are yet, read the section on [code blocks] first.)  This can be
useful when you want to set the values of multiple variables with one
button.

{% highlight yaml %}
---
question: What kind of car do you want?
buttons:
  - Ford Focus:
    code: |
      car_model = "Focus"
	  car_make = "Ford"
  - Toyota Camry:
    code: |
      car_model = "Camry"
      car_make = "Toyota"
---
{% endhighlight %}

The question above tells **docassemble** that if the interview logic
calls for either `car_model` or `car_make`, the question should be
tried.  When the user clicks on one of the buttons, the code will be
executed and the variables will be set.

[configuration]: {{ site.baseurl }}/docs/configuration.html
[select]: http://www.w3schools.com/tags/tag_select.asp
[placeholder]: http://www.w3schools.com/tags/att_input_placeholder.asp
[code blocks]: {{ site.baseurl }}/docs/code.html
[Mako]: http://www.makotemplates.org/
[Markdown]: https://daringfireball.net/projects/markdown/
[YAML]: [YAML]: https://en.wikipedia.org/wiki/YAML