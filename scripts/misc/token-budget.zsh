#!/usr/bin/env zsh

set +x
setopt no_xtrace


# Pure zsh implementation (platform-independent)
get_last_day_of_month() {
  local year=${1%%-*}
  local month=$(( 10#${1##*-} ))
  local days
  case $month in
    1|3|5|7|8|10|12) days=31 ;;
    4|6|9|11)        days=30 ;;
    2) (( year % 400 == 0 || (year % 4 == 0 && year % 100 != 0) )) && days=29 || days=28 ;;
  esac
  echo $days
}

# Get day of week using Sakamoto's algorithm (0=Sunday, 1=Monday, ..., 6=Saturday)
# Convert to 1=Monday, ..., 7=Sunday for compatibility
get_day_of_week() {
  local year=$1 month=$2 day=$3
  local t=(0 3 2 5 0 3 5 1 4 6 2 4)
  (( month < 3 )) && (( year-- ))
  local dow=$(( (year + year/4 - year/100 + year/400 + t[month] + day) % 7 ))
  # Convert: 0=Sun, 1=Mon, ... -> 1=Mon, ..., 7=Sun
  (( dow == 0 )) && echo 7 || echo $dow
}

# Get current date command for default TODAY
DATE_CMD="date"
if command -v gdate >/dev/null 2>&1; then
  DATE_CMD="gdate"
fi

# -----------------------------
# CONFIG
# -----------------------------

DEFAULT_BUDGET=400

# Convert holidays to YYYYMMDD integers for faster comparison
typeset -a HOLIDAY_RANGES
HOLIDAY_ENTRIES=(
  "2026-07-03"
  "2026-07-06:2026-07-10"
  "2026-09-07"
  "2026-11-26:2026-11-27"
  "2026-12-24:2026-12-25"
)

# -----------------------------
# INPUTS
# -----------------------------

PERCENT_USED=${1:-0}
TODAY=${2:-$($DATE_CMD +%Y-%m-%d)}

CURRENT_YEAR=${TODAY%%-*}
CURRENT_MONTH=$(( 10#${${TODAY#*-}%%-*} ))

# Filter and clip HOLIDAY_ENTRIES to exclude past entries and clip in-progress entries
typeset -a ACTIVE_HOLIDAY_ENTRIES
local today_int=$(( 10#${TODAY//-} ))

for entry in "${HOLIDAY_ENTRIES[@]}"; do
  e_start=""
  e_end=""
  if [[ "$entry" == *:* ]]; then
    e_start="${entry%%:*}"
    e_end="${entry##*:}"
  else
    e_start="$entry"
    e_end="$entry"
  fi

  s_int=$(( 10#${e_start//-} ))
  end_int=$(( 10#${e_end//-} ))

  # Entirely in the past — skip
  (( end_int < today_int )) && continue

  # Currently in progress — clip start to today
  if (( s_int < today_int )); then
    e_start="$TODAY"
  fi

  # Rebuild entry string
  if [[ "$e_start" == "$e_end" ]]; then
    ACTIVE_HOLIDAY_ENTRIES+=("$e_start")
  else
    ACTIVE_HOLIDAY_ENTRIES+=("$e_start:$e_end")
  fi
done

# Build HOLIDAY_RANGES from ACTIVE_HOLIDAY_ENTRIES for fast lookup in is_holiday()
for entry in "${ACTIVE_HOLIDAY_ENTRIES[@]}"; do
  if [[ "$entry" == *:* ]]; then
    start=${entry%%:*}
    end=${entry##*:}
    HOLIDAY_RANGES+=($(( 10#${start//-} ))  $(( 10#${end//-} )))
  else
    HOLIDAY_RANGES+=($(( 10#${entry//-} ))  $(( 10#${entry//-} )))
  fi
done

# -----------------------------
# HELPERS
# -----------------------------

function is_holiday() {
  local date_int=$1
  
  for (( i=1; i<=${#HOLIDAY_RANGES[@]}; i+=2 )); do
    local start=${HOLIDAY_RANGES[$i]}
    local end=${HOLIDAY_RANGES[$((i+1))]}
    
    (( date_int >= start && date_int <= end )) && return 0
  done
  
  return 1
}

function format_pto_for_month() {
  local year=$1 month=$2
  local month_names=(Jan Feb Mar Apr May Jun Jul Aug Sept Oct Nov Dec)
  local month_abbr=${month_names[$month]}
  local month_first=$((year * 10000 + month * 100 + 1))
  local last_day
  
  case $month in
    1|3|5|7|8|10|12) last_day=31 ;;
    4|6|9|11)        last_day=30 ;;
    2) (( year % 400 == 0 || (year % 4 == 0 && year % 100 != 0) )) && last_day=29 || last_day=28 ;;
  esac
  
  local month_last=$((year * 10000 + month * 100 + last_day))
  local -a segments
  local total_days=0
  
  for entry in "${ACTIVE_HOLIDAY_ENTRIES[@]}"; do
    local s_date e_date
    [[ "$entry" == *:* ]] && { s_date="${entry%%:*}"; e_date="${entry##*:}"; } || { s_date="$entry"; e_date="$entry"; }
    
    local s_int=$(( 10#${s_date//-} )) e_int=$(( 10#${e_date//-} ))
    (( s_int < month_first )) && s_int=$month_first
    (( e_int > month_last )) && e_int=$month_last
    
    if (( s_int <= e_int )); then
      local s_d=$(( s_int % 100 )) e_d=$(( e_int % 100 ))
      local seg
      if (( s_d == e_d )); then
        seg="${month_abbr} ${s_d}"
      else
        seg="${month_abbr} ${s_d}–${e_d}"
      fi
      segments+=("$seg")
      (( total_days += e_int - s_int + 1 ))
    fi
  done
  
  [[ ${#segments[@]} -eq 0 ]] && { echo "—"; return 0; }
  local day_text="days"
  (( total_days == 1 )) && day_text="day"
  echo "${(j|; |)segments[@]} ($total_days $day_text)"
}

function count_workdays() {
   local start="$1"
   local end="$2"
   
   local start_year=${start%%-*}
   local start_month=$(( 10#${${start#*-}%%-*} ))
   local start_day=$(( 10#${start##*-} ))
   
   local end_year=${end%%-*}
   local end_month=$(( 10#${${end#*-}%%-*} ))
   local end_day=$(( 10#${end##*-} ))
   
   local year=$start_year
   local month=$start_month
   local day=$start_day
   
   local count=0
   
   while true; do
     local date_int=$(( year * 10000 + month * 100 + day ))
     local end_int=$(( end_year * 10000 + end_month * 100 + end_day ))
     
     (( date_int > end_int )) && break
     
     local dow=$(get_day_of_week "$year" "$month" "$day")
     
     if (( dow <= 5 )) && ! is_holiday "$date_int"; then
       ((count++))
     fi
     
     # Increment to next day
     ((day++))
     local days_in_month=$(get_last_day_of_month "$year-$(printf "%02d" $month)")
     if (( day > days_in_month )); then
       day=1
       ((month++))
       if (( month > 12 )); then
         month=1
         ((year++))
       fi
     fi
   done
   
   echo $count
}

function count_weekdays() {
   local start="$1"
   local end="$2"
   
   local start_year=${start%%-*}
   local start_month=$(( 10#${${start#*-}%%-*} ))
   local start_day=$(( 10#${start##*-} ))
   
   local end_year=${end%%-*}
   local end_month=$(( 10#${${end#*-}%%-*} ))
   local end_day=$(( 10#${end##*-} ))
   
   local year=$start_year
   local month=$start_month
   local day=$start_day
   
   local count=0
   
   while true; do
     local date_int=$(( year * 10000 + month * 100 + day ))
     local end_int=$(( end_year * 10000 + end_month * 100 + end_day ))
     
     (( date_int > end_int )) && break
     
     local dow=$(get_day_of_week "$year" "$month" "$day")
     
     if (( dow <= 5 )); then
       ((count++))
     fi
     
     # Increment to next day
     ((day++))
     local days_in_month=$(get_last_day_of_month "$year-$(printf "%02d" $month)")
     if (( day > days_in_month )); then
       day=1
       ((month++))
       if (( month > 12 )); then
         month=1
         ((year++))
       fi
     fi
   done
   
   echo $count
}



# -----------------------------
# OUTPUT
# -----

local month_names=(January February March April May June July August September October November December)

typeset -a months weekdays pto_labels net_workdays per_days per_weeks percentages

for m in $(seq 1 12); do
  (( m < CURRENT_MONTH )) && continue

  start=$(printf "%04d-%02d-01" "$CURRENT_YEAR" "$m")
  local last_day=$(get_last_day_of_month "$CURRENT_YEAR-$(printf "%02d" "$m")")
  end=$(printf "%04d-%02d-%02d" "$CURRENT_YEAR" "$m" "$last_day")

  full_net=$(count_workdays "$start" "$end")
  (( full_net == 0 )) && continue
  
  full_weekdays=$(count_weekdays "$start" "$end")

   if (( m == CURRENT_MONTH )); then
      remaining_net=$(count_workdays "$TODAY" "$end")
      remaining_weekdays=$(count_weekdays "$TODAY" "$end")

      if (( PERCENT_USED > 0 && remaining_net > 0 )); then
        remaining_pct=$(echo "100 - $PERCENT_USED" | bc)
        remaining_budget=$(echo "$DEFAULT_BUDGET * $remaining_pct / 100" | bc -l)
        per_day=$(printf "%.2f" "$(echo "$remaining_budget / $remaining_net" | bc -l)")
        pct=$(printf "%.2f" "$(echo "$remaining_pct / $remaining_net" | bc -l)")
        net=$remaining_net
        wkd=$remaining_weekdays
      else
        per_day=$(printf "%.2f" "$(echo "$DEFAULT_BUDGET / $full_net" | bc -l)")
        pct=$(printf "%.2f" "$(echo "100 / $remaining_net" | bc -l)")
        net=$remaining_net
        wkd=$remaining_weekdays
      fi
      
      month_label="${month_names[$m]} (remaining)"
    else
      net=$full_net
      wkd=$full_weekdays
      per_day=$(printf "%.2f" "$(echo "$DEFAULT_BUDGET / $net" | bc -l)")
      pct=$(printf "%.2f" "$(echo "100 / $full_net" | bc -l)")
      month_label="${month_names[$m]}"
    fi

    (( net <= 0 )) && continue

    per_week=$(printf "%.2f" "$(echo "$per_day * 5" | bc -l)")
    pto_label=$( { format_pto_for_month "$CURRENT_YEAR" "$m"; } 2>&1 | tail -1)

   months+=("$month_label")
   weekdays+=("$wkd")
   pto_labels+=("$pto_label")
   net_workdays+=("$net")
   per_days+=("$per_day")
   per_weeks+=("$per_week")
   percentages+=("$pct")
done

# Compute column widths
local col_month=16 col_wkd=8 col_pto=26 col_net=8 col_day=5 col_week=6 col_pct=5

for (( i=1; i<=${#months[@]}; i++ )); do
  local m=${#months[$i]}
  local w=${#weekdays[$i]}
  local p=${#pto_labels[$i]}
  local n=${#net_workdays[$i]}
  local d=${#per_days[$i]}
  local wk=${#per_weeks[$i]}
  local pc=${#percentages[$i]}
  
  (( m > col_month )) && col_month=$m
  (( w > col_wkd )) && col_wkd=$w
  (( p > col_pto )) && col_pto=$p
  (( n > col_net )) && col_net=$n
  (( d > col_day )) && col_day=$d
  (( wk > col_week )) && col_week=$wk
  (( pc > col_pct )) && col_pct=$pc
done

# Print header
printf "| %-${col_month}s | %${col_wkd}s | %-${col_pto}s | %${col_net}s | $ %${col_day}s | $ %${col_week}s | %${col_pct}s %% |\n" \
  "Month" "Weekdays" "PTO / Holidays" "Workdays" "/ Day" "/ Week" "/ Day"

# Print separator
printf "|%s|%s|%s|%s|%s|%s|%s|\n" \
  "$(printf '%-*s' $((col_month + 2)) '' | tr ' ' '-')" \
  "$(printf '%-*s' $((col_wkd + 2)) '' | tr ' ' '-')" \
  "$(printf '%-*s' $((col_pto + 2)) '' | tr ' ' '-')" \
  "$(printf '%-*s' $((col_net + 2)) '' | tr ' ' '-')" \
  "$(printf '%-*s' $((col_day + 4)) '' | tr ' ' '-')" \
  "$(printf '%-*s' $((col_week + 4)) '' | tr ' ' '-')" \
  "$(printf '%-*s' $((col_pct + 4)) '' | tr ' ' '-')"

# Print rows
for (( i=1; i<=${#months[@]}; i++ )); do
  printf "| %-${col_month}s | %${col_wkd}s | %-${col_pto}s | %${col_net}s | $ %${col_day}s | $ %${col_week}s | %${col_pct}s %% |\n" \
    "${months[$i]}" "${weekdays[$i]}" "${pto_labels[$i]}" "${net_workdays[$i]}" "${per_days[$i]}" "${per_weeks[$i]}" "${percentages[$i]}"
done
