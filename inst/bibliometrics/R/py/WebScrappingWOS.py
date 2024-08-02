from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time
import pandas as pd

def inicializar_navegador():
    options = webdriver.ChromeOptions()
    options.add_argument('--start-maximized')
    options.add_argument('--disable-extensions')
    options.add_argument("--incognito")
    #driver_path = 'C:\\SeleniumDrivers\\chromedriver.exe'
    driver = webdriver.Chrome(options=options)
    driver.get("https://idp.fecyt.es/adas/SAML2/SSOService.php?SAMLRequest=fZJfb4IwFMW%2FCum7%2FFN0NkLC9GEmbhJhe9jLUsplNIGW9ZY5v%2F1AXOaSxcebnnvOPb90haypWxp3ppIH%2BOgAjfXV1BLp%2BSEknZZUMRRIJWsAqeE0jR931Ldd2mplFFc1sWJE0EYouVYSuwZ0CvpTcHg%2B7EJSGdMidZyjQrsEfjI2oMM4B1ROWok8VzWYysZh7K19J9mnGbE2%2FS1CssH110MU7ZVHwfCykqb7S6TdVi2xtpuQvLmzADzgJcAicP2gnHtsuSxzXgQLNi%2Bnd70MsYOtRMOkCYnv%2BrOJu5i4y8xdUM%2Bjs%2BkrsZJLy3shCyHfbyPJRxHShyxLJmORF9B4LtELSLQawNJzsL5CfduW%2FfAl0UBigHk82hp4p1EhFyCNKAX%2FB%2FDKucobw1v61AdsN4mqBT9ZcV2r41oDMxASjzjRuPL3U0Tf&RelayState=cookie%3A1720509103_b9a7")
    return driver



driver = inicializar_navegador()
wait = WebDriverWait(driver, 25)
select_element = wait.until(EC.element_to_be_clickable((By.XPATH, '//*[@id="dfeds"]/span/span[1]/span')))
select_element.click()
time.sleep(1)




def getMetrics(query):
    input = wait.until(EC.element_to_be_clickable((By.XPATH,'/html/body/span/span/span[1]/input')))
    input.send_keys("Universidad de Jaén")


    time.sleep(2) 

    input.send_keys(Keys.ENTER)



    boton = wait.until(EC.element_to_be_clickable((By.XPATH, '//*[@id="form_submit_wayf"]')))
    boton.click()

    time.sleep(2)

    input = wait.until(EC.element_to_be_clickable((By.XPATH,'//*[@id="username"]')))
    input.send_keys("jmjr0007")

    input = wait.until(EC.element_to_be_clickable((By.XPATH, '//*[@id="password"]')))
    input.send_keys("Juanmiguel0!")

    boton = wait.until(EC.element_to_be_clickable((By.XPATH, '//*[@id="submit_button"]')))
    boton.click()

    boton = wait.until(EC.element_to_be_clickable((By.XPATH, '//*[@id="onetrust-reject-all-handler"]')))
    boton.click()

    time.sleep(5)

    driver.get("https://www.webofscience.com/wos/alldb/full-record/"+query)
   
    button1 = wait.until(EC.presence_of_element_located((By.XPATH, '(//button[descendant::span[@class="font-size-26" and text()="3.3"]])[1]')))
    button1.click()


    close = wait.until(EC.element_to_be_clickable((By.XPATH,'//*[@id="snJournalData"]/span/div[2]/div[1]/div[1]/app-jcr-sidenav/mat-sidenav-container/mat-sidenav/div/div[2]/div[1]/button')))
    close.click()

    button2 = wait.until(EC.presence_of_element_located((By.CSS_SELECTOR, 'button[data-ta="jcrSidenav-3-jcr-citation-indicator"]')))
    button2.click()

    time.sleep(3)



getMetrics("WOS:001008886600001")
