#!/usr/bin/env python3
"""
Moon phase calculator using the astral library.
Returns today's moon phase as JSON for waybar consumption.
"""

from astral import LocationInfo
from astral.moon import moonrise, moonset
from astral.sun import sun
from astral import moon
import datetime
import json
import sys
from pathlib import Path

def load_location():
    config_file = Path.home() / ".config" / "location.json"
    with open(config_file) as f:
        return json.load(f)["location"]

def create_location_info():
    loc_data = load_location()
    return LocationInfo(
        name=loc_data["name"],
        region=loc_data["country"], 
        timezone=loc_data["timezone"],
        latitude=loc_data["latitude"],
        longitude=loc_data["longitude"]
    )        

def get_sun_moon_times():
    """
    Get sunrise/set and moonrise/set times for today.

    Returns:
        tuple: (sun_rise, sun_set, moon_rise, moon_set)
    """
    city = create_location_info()
    today = datetime.date.today()

    # Arctic-proof sun data
    try:
        s = sun(city.observer, date=today)
        sun_rise = s['sunrise'].astimezone().strftime('%H:%M')
        sun_set = s['sunset'].astimezone().strftime('%H:%M')
    except Exception as e:
        sun_rise = "No sunrise"
        sun_set = "No sunset"

    # Arctic-proof moon data
    try:
        moon_rise = moonrise(city.observer, date=today).astimezone().strftime('%H:%M')
    except:
        moon_rise = "No rise"
        
    try:
        moon_set = moonset(city.observer, date=today).astimezone().strftime('%H:%M')
    except:
        moon_set = "No set"

    return sun_rise, sun_set, moon_rise, moon_set

def get_moon_phase_today():
    """
    Get moon phase information for today.
    
    Returns:
        tuple: (age_days, phase_name, icon)
    """
    # Get moon age in days since new moon
    age = moon.phase(datetime.datetime.today())
    age_days = int(age)
    
    # Define phase names, icons, and their day ranges
    # Lunar cycle is ~29.5 days
    phase_data = [
        ("New Moon", "󰽤"),         # 0-1 days
        ("Waxing Crescent", ""),  # 2-6 days  
        ("First Quarter", ""),    # 7-8 days
        ("Waxing Gibbous", ""),   # 9-13 days
        ("Full Moon", ""),        # 14-15 days
        ("Waning Gibbous", "󰽦"),  # 16-21 days
        ("Last Quarter", ""),     # 22-23 days
        ("Waning Crescent", "")   # 24-28+ days
    ]

    # Map age to phase
    if age_days <= 1:
        phase_name, icon = phase_data[0]
    elif age_days <= 6:
        phase_name, icon = phase_data[1]
    elif age_days <= 8:
        phase_name, icon = phase_data[2]
    elif age_days <= 13:
        phase_name, icon = phase_data[3]
    elif age_days <= 15:
        phase_name, icon = phase_data[4]
    elif age_days <= 21:
        phase_name, icon = phase_data[5]
    elif age_days <= 23:
        phase_name, icon = phase_data[6]
    else:
        phase_name, icon = phase_data[7]
    
    return age_days, phase_name, icon

def get_days_to_next_phase(age_days):
    """
    Calculate days to next significant moon phase or show current phase if we're in it.
    
    Returns:
        tuple: (is_special, days_remaining_or_message, target_icon)
    """
    # New moon window: days 0, 1, and 29 (wrapping around)
    if age_days == 0 or age_days == 1 or age_days >= 28:
        return True, "New Moon!", "󰽤"
    
    # Full moon window: days 13, 14, 15
    elif 13 <= age_days <= 15:
        return True, "Full Moon!", ""
    
    # First half of cycle (after new moon window, before full moon)
    elif age_days <= 12:
        days_to_full = 14 - age_days
        return False, f"  {days_to_full} days to", ""
    
    # Second half of cycle (after full moon window, before new moon)
    else:  # age_days is 16-27
        days_to_new = 29 - age_days
        return False, f"  {days_to_new} days to", "󰽤"

def main():
    """Main function for command line usage."""
    try:
        age_days, phase_name, icon = get_moon_phase_today()
        sun_rise, sun_set, moon_rise, moon_set = get_sun_moon_times()
        is_special, days_info, target_icon = get_days_to_next_phase(age_days)

        # Set CSS class based on special status
        css_class = "moon-phase-special" if is_special else "moon-phase"

        moon_line = f"  {moon_rise}             {moon_set}"
        sun_line  = f"󰖜  {sun_rise}           󰖛  {sun_set}"

        line_length = max(len(moon_line), len(sun_line))

        # Combine the message parts
        if not is_special:
            centered_days = f"{days_info:^{line_length - 22}}"  # Reduce width to account for spaces
            phase_message = f"  {centered_days.rstrip()}  {target_icon}"
        else:
            phase_message = days_info  # Just "New Moon!" or "Full Moon!"
            phase_name = ""


        # Create waybar JSON output
        output = {
            "text": icon,
            "tooltip": f"{phase_name:^{line_length}}\n{phase_message:^{line_length}}\n\n{moon_line}\n{sun_line}",
            "class": css_class
        }

        # Output as compact JSON
        print(json.dumps(output, ensure_ascii=False))
        # print(output["tooltip"])
        
    except Exception as e:
        # Fallback JSON in case of any errors
        error_output = {
            "text": "󰽧",
            "tooltip": f"Error calculating moon phase: {str(e)}",
            "class": "moon-phase-error"
        }
        print(json.dumps(error_output, ensure_ascii=False))
        sys.exit(1)

if __name__ == "__main__":
    main()