## 0.6.1 - October 20, 2015

- Make `once` and `times(n)` modifiers play nicely with other jobs being enqueued - patch
  by [@basawyer](https://github.com/basawyer)

## 0.6.0 - October 15, 2015

- Add `once` and `times(n)` modifiers - patch by [@antstorm](https://github.com/antstorm)

## 0.5.0 - September 16, 2015

- Add `to_run_at` modifier - patch by [@vidmantas](https://github.com/vidmantas)

## 0.4.2 - August 19, 2015

- Improve `failure_message_negated` - patch by [@swastik](https://github.com/swastik)

## 0.4.1 - May 5, 2015

- Added `failure_message_negated` for nice failure messages when a `to_not` fails

## 0.4.0 - April 20, 2015

- Added the `have_been_enqueued` matcher

## 0.3.0 - March 21, 2015

- Added the `deserialize_as` matcher

## 0.2.0 - January 21, 2015

- Added the `global_id` matcher

## 0.1.0 - January 18, 2015

- Added support for argument matchers (e.g. `instance_of`, `hash_including`), like the `receive` matcher.
