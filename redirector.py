import time
import redis
import pymongo
from pymongo import MongoClient
client = MongoClient('localhost', 27017)
db = client['redirects']
redirects = db.redirects
r = redis.StrictRedis(host='localhost', port=6379, db=0)
from selenium import webdriver
import numpy as np
import json
latest = "https://permanent-redirect.xyz/pages/1515462547"
click_count = 0
driver = webdriver.Chrome("./chromedriver")
driver.get(latest)
while True:
    if len(driver.find_elements_by_tag_name("a")) == 2:
        sleep(20)
        driver.refresh()
    else:
        latest = driver.find_elements_by_tag_name("a")[0].get_attribute("href")
        driver.find_elements_by_tag_name("a")[0].click()
        latest_id = str.split(str(latest), "/")[-1]
        timestamp = str.split(str(driver.find_elements_by_tag_name("p")[1].text), "created at ")[-1]
        click_count += 1
        present_on_page = int(str.join("", [str(el.get_attribute("alt")) for el in driver.find_elements_by_tag_name("img")]))
        current_status = {"time": time.time(), "page_visitors": present_on_page, "clicked_link": latest, "latest_id": latest_id, "timestamp": timestamp, "click_count": click_count}
        result = redirects.insert(current_status)
        r.set("redirect_current_status", current_status)
