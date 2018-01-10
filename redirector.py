from selenium import webdriver
import numpy as np
import json
driver = webdriver.Chrome("./chromedriver")
latest = "https://permanent-redirect.xyz/pages/1515462547"
driver.get(latest)
click_count = 0
while True:
  latest = driver.find_elements_by_tag_name("a")[0].get_attribute("href")
  driver.find_elements_by_tag_name("a")[0].click()
  latest_id = str.split(str(latest), "/")[-1]
  timestamp = str.split(str(driver.find_elements_by_tag_name("p")[1].text), "created at ")[-1]
  click_count += 1
  present_on_page = int(str.join("", [str(el.get_attribute("alt")) for el in driver.find_elements_by_tag_name("img")]))
  print json.dumps({"page_visitors": present_on_page, "clicked_link": latest, "latest_id": latest_id, "timestamp": timestamp, "click_count": click_count})
