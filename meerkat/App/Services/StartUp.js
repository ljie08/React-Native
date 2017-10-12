import { create } from 'apisauce'

import { domains } from '../Config/AppConfig';

const StartUp = (baseURL = domains[0]) => {
  const api = create({
    baseURL: baseURL,
    timeout: 5000,
    headers: {
      'Cache-Control': 'no-cache'
    }
  })
  if (__DEV__ && console.tron) {
    api.addMonitor(console.tron.apisauce)
  }
  const checkIpInfo = api.get('/update/checkIpInfo')
  return {
    checkIpInfo
  }
}

export default { StartUp }

