from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from selenium.common.exceptions import NoSuchElementException
import time
import pandas as pd

def inicializar_navegador():
    options = webdriver.ChromeOptions()
    options.add_argument('--start-maximized')
    options.add_argument('--disable-extensions')
    options.add_argument("--incognito")
    options.add_argument("--headless")  
    options.add_argument("--disable-gpu")  
    options.add_argument("--no-sandbox")  
    options.add_argument("--disable-dev-shm-usage")  
    driver = webdriver.Chrome(options=options)
    driver.get("https://id.elsevier.com/as/authorization.oauth2?platSite=SC%2Fscopus&ui_locales=en-US&scope=openid+profile+email+els_auth_info+els_analytics_info+urn%3Acom%3Aelsevier%3Aidp%3Apolicy%3Aproduct%3Ainst_assoc&response_type=code&redirect_uri=https%3A%2F%2Fwww.scopus.com%2Fauthredirect.uri%3FtxGid%3Dd3e4f5229e01cf39b42f98ff6727d663&state=checkAccessLogin%7CtxId%3D4DA899C2C8F205AF72D685A395F29A66.i-0d6d1bed1b3ca8930%3A4&authType=SINGLE_SIGN_IN&prompt=login&client_id=SCOPUS")
    return driver

def safe_find_element(driver, by, value):
    try:
        return driver.find_element(by, value).text
    except:
        return None



def getMetrics(eid, user, password):
    driver = inicializar_navegador()
    time.sleep(4)
    select_element = driver.find_element(By.XPATH, '//*[@id="onetrust-accept-btn-handler"]')
    select_element.click()

    time.sleep(1)

    input = driver.find_element(By.XPATH, '//*[@id="bdd-email"]')
    input.send_keys(user+"@red.ujaen.es")

    time.sleep(1)

    button = driver.find_element(By.XPATH, '//button[@id="bdd-els-searchBtn"]')
    button.click()

    time.sleep(1)

    button = driver.find_element(By.XPATH, '//*[@id="bdd-elsPrimaryBtn3"]')
    button.click()

    time.sleep(2)
    
    try:
        element = driver.find_element(By.XPATH, "//div[contains(text(), 'SIDUJA Servicio de Identidad - Universidad de Jaén')]")
        element.click()
    except NoSuchElementException:
        pass

    time.sleep(2)

    input = driver.find_element(By.XPATH, '//*[@id="username"]')
    input.send_keys(user)

    input = driver.find_element(By.XPATH, '//*[@id="password"]')
    input.send_keys(password)

    button = driver.find_element(By.XPATH, '//*[@id="submit_button"]')
    button.click()

    time.sleep(5)

    driver.get("https://www.scopus.com/record/display.uri?eid=" + eid + "&origin=resultslist&sort")

    time.sleep(3)

    try:
    
      button = driver.find_element(By.XPATH, '//*[@id="doc-details-page-container"]/article/div[2]/div[2]/section/div[3]/div/div[2]/div[2]/div/button')
      button.click()
  
      time.sleep(3)
  
      data = {}
      
      data['scopus_metrics'] = {
          'citations_in_scopus': safe_find_element(driver, By.XPATH, '//*[@data-testid="unclickable-count"]'),
          'percentile': safe_find_element(driver, By.XPATH, '//*[@class="info-field-module__DPYRH"]'),
          'field_weighted_citation_impact': safe_find_element(driver, By.XPATH, '//*[@data-testid="clickable-count"]')
      }
  
      data['views_count'] = {
          'total_views': safe_find_element(driver, By.XPATH, '//*[@id="metrics"]/div/section[1]/div[2]/div[2]/div/div/div/div/div/div[1]/span'),
          'years': safe_find_element(driver, By.XPATH, '//*[@id="metrics"]/div/section[1]/div[2]/div[2]/div/div/div/div/div/div[2]/span/span')
      }
  
      data['plumx_metrics'] = {
          'captures': {
              'readers': safe_find_element(driver, By.XPATH, '//*[@id="metrics"]/div/section[2]/div[2]/div/div/div/div/div/div/div[1]/span')
          },
          'mentions': {
              'news_mentions': safe_find_element(driver, By.XPATH, '//*[@id="metrics"]/div/section[2]/div[3]/div/div[1]/div/div/div/div/div[1]/span'),
              'blog_mentions': safe_find_element(driver, By.XPATH, '//*[@id="metrics"]/div/section[2]/div[3]/div/div[2]/div/div/div/div/div[1]/span'),
              'references': safe_find_element(driver, By.XPATH, '//*[@id="metrics"]/div/section[2]/div[3]/div/div[3]/div/div/div/div/div[1]/span')
          },
          'social': {
              'Shares, Likes & Comments': safe_find_element(driver, By.XPATH, '//*[@id="metrics"]/div/section[2]/div[5]/div/div/div/div/div/div/div[1]/span')
          }
      }

    except:
        data = {}
        
        data['scopus_metrics'] = {
            'citations_in_scopus': None,
            'percentile': None,
            'field_weighted_citation_impact': None
        }

        data['views_count'] = {
            'total_views': None,
            'years': None
        }

        data['plumx_metrics'] = {
            'captures': {
                'readers': None
            },
            'mentions': {
                'news_mentions': None,
                'blog_mentions': None,
      
                'references': None
            },
            'social': {
                'Shares, Likes & Comments': None
            }
        }

    return data

