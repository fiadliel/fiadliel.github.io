import Time
import Date

dateSignal : Signal Date.Date

dateSignal = Date.fromTime <~ Time.every second

main = asText <~ dateSignal
