import Time
import Date

dateSignal : Signal Date.Date

dateSignal = Date.fromTime <~ Time.every second

secondSignal: Signal Int

secondSignal = Date.second <~ dateSignal

main = asText <~ secondSignal
