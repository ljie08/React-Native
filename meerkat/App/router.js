import React, {
  PureComponent
} from 'react'

import {
  BackAndroid,
  Animated,
  Easing,
  View,
  Text,
  Dimensions,
  TouchableOpacity,
  AsyncStorage,
  Platform,
  NativeModules
} from 'react-native'
import {
  StackNavigator,
  TabNavigator,
  TabBarBottom,
  addNavigationHelpers,
  NavigationActions
} from 'react-navigation'
import {
  connect
} from 'dva'
import AppConfig from './Config/AppConfig'
import StartUpHelper from './utils/StartUpHelper'
import Login from './Containers/Login'
import * as Progress from 'react-native-progress'
import Home from './Containers/Home'
import Account from './Containers/Account'
import Detail from './Containers/Detail'
import create from './Services/Api'
import CodePush from 'react-native-code-push'
import TopNavigationBar from './Navigation/TCNavigationBar';

import NetWorkTool from './utils/TCToolNetWork'

import Moment from 'moment'
const width = Dimensions.get('window').width
let retryTimes = 0
let downloadTime = 0
let alreadyInCodePush = false

const HomeNavigator = TabNavigator({
  Home: {
    screen: Home
  },
  Account: {
    screen: Account
  },
}, {
  tabBarComponent: TabBarBottom,
  tabBarPosition: 'bottom',
  swipeEnabled: false,
  animationEnabled: false,
  lazyLoad: true,
})

const MainNavigator = StackNavigator({
  HomeNavigator: {
    screen: HomeNavigator
  },
  Detail: {
    screen: Detail
  },
}, {
  headerMode: 'float',
})

const AppNavigator = StackNavigator({
  Main: {
    screen: MainNavigator
  },
  Login: {
    screen: Login
  },
}, {
  headerMode: 'none',
  mode: 'modal',
  navigationOptions: {
    gesturesEnabled: false,
  },
  transitionConfig: () => ({
    transitionSpec: {
      duration: 300,
      easing: Easing.out(Easing.poly(4)),
      timing: Animated.timing,
    },
    screenInterpolator: sceneProps => {
      const {
        layout,
        position,
        scene
      } = sceneProps
      const {
        index
      } = scene

      const height = layout.initHeight
      const translateY = position.interpolate({
        inputRange: [index - 1, index, index + 1],
        outputRange: [height, 0, 0],
      })

      const opacity = position.interpolate({
        inputRange: [index - 1, index - 0.99, index],
        outputRange: [0, 1, 1],
      })
      return {
        opacity,
        transform: [{
          translateY
        }]
      }
    }
  })
})

function getCurrentScreen(navigationState) {
  if (!navigationState) {
    return null
  }
  const route = navigationState.routes[navigationState.index]
  if (route.routes) {
    return getCurrentScreen(route)
  }
  return route.routeName
}

class Router extends PureComponent {

  constructor() {
    super()
    this.state = {
      updateFinished: false,
      syncMessage: '初始化配置中...',
      updateStatus: 0,
    }
    this.initStart = this.initStart.bind(this)
  }


  skipUpdate() {
    this.setState({
      progress: false,
      updateFinished: true,
      updateStatus: 0
    })
  }

  finalFailRoute() {
    Platform.OS === 'ios' ? NativeModules.JXCodepush.resetLoadModleForJS(false) : null
  }

  //使用默认地址
  firstAttempt(success, allowUpdate, message) {
    console.log(`first attempt ${success}, ${allowUpdate}, ${message}`)
    if (success && allowUpdate) {
      this.gotoUpdate()
    } else if (!success) {
      //默认地址不可用，使用备份地址
      StartUpHelper.getAvailableDomain(AppConfig.backupDomains, (success, allowUpdate, message) => this.secondAttempt(success, allowUpdate, message))
    } else {
      //不允许更新
      this.skipUpdate()
    }
  }

  //使用默认备份地址
  secondAttempt(success, allowUpdate, message) {
    if (success && allowUpdate) {
      this.gotoUpdate()
    } else if (!success) {
      //备份地址不可用
      // Toast User to change a better network and retry
      let customerMessage = "当前网络无法更新，可能是请求域名的问题"
      switch (message) {
        case 'NETWORK_ERROR':
          customerMessage = "当前没有网络，请打开网络"
          break
        case 'CONNECTION_ERROR':
          customerMessage = "服务器无返回结果，DNS无法访问"
          break
        case 'TIMEOUT_ERROR':
          customerMessage = "当前网络差，请换更快的网络"
          break
        case 'SERVER_ERROR':
          customerMessage = "服务器错误"
          break
        default:
          break
      }

      setTimeout(() => {
        this.initStart()
      }, 1500)

      this.storeLog({
        faileMessage: customerMessage
      })
      this.setState({
        syncMessage: customerMessage,
        updateFinished: false,
        updateStatus: -1
      })
    } else {
      // TODO 审核通过之后 放开如下，告知ip不在更新范围内的用户
      // alert('您当前的区域无法更新')

      this.skipUpdate()
    }
  }

  //使用缓存地址
  cacheAttempt(success, allowUpdate, message) {
    console.log(`first attempt ${success}, ${allowUpdate}, ${message}`)
    if (success && allowUpdate) {
      this.gotoUpdate()
    } else if (!success) { //缓存地址不可用,使用默认地址
      StartUpHelper.getAvailableDomain(AppConfig.domains, (success, allowUpdate, message) => this.firstAttempt(success, allowUpdate, message))
    } else {
      this.skipUpdate()
    }
  }

  //使用从服务器获取的更新地址更新app
  gotoUpdate() {
    AsyncStorage.getItem('cacheDomain').then((response) => {
      let cacheDomain = JSON.parse(response)
      global.JXCodePushServerUrl = cacheDomain.hotfixDomains[0].domain
      let hotfixDeploymentKey = Platform.OS == 'ios' ? cacheDomain.hotfixDomains[0].iosDeploymentKey : cacheDomain.hotfixDomains[0].androidDeploymentKey
      if (!__DEV__) {
        this.hotFix(hotfixDeploymentKey)
      }
    })
  }

  storeLog(message) {
    AsyncStorage.mergeItem('uploadLog', JSON.stringify(message))
  }

  componentWillMount() {
    this.initStart()
    BackAndroid.addEventListener('hardwareBackPress', this.backHandle)
    NetWorkTool.addEventListener(NetWorkTool.TAG_NETWORK_CHANGE, this.handleMethod)
  }

  handleMethod(isConnected) {
    if (isConnected) {
      this.initStart
    }
  }

  initStart() {
    this.initData()
    this.uploadLog()
    this.initDomain()
  }

  componentWillUnmount() {
    NetWorkTool.removeEventListener(NetWorkTool.TAG_NETWORK_CHANGE, this.handleMethod)
    this.listener && this.listener.remove()
    this.timer && clearTimeout(this.timer)
  }

  initDomain() {
    AsyncStorage.getItem('cacheDomain').then((response) => {
      console.log("refresh cache domain ", response)
      let cacheDomain = response ? JSON.parse(response) : null
      if (cacheDomain != null && cacheDomain.serverDomains && cacheDomain.serverDomains.length > 0) {
        //缓存存在，使用缓存访问
        StartUpHelper.getAvailableDomain(cacheDomain.serverDomains, (success, allowUpdate, message) => this.cacheAttempt(success, allowUpdate, message))
      } else {
        //缓存不存在，使用默认地址访问
        StartUpHelper.getAvailableDomain(AppConfig.domains, (success, allowUpdate, message) => this.firstAttempt(success, allowUpdate, message))
      }
    }).catch((error) => {
      StartUpHelper.getAvailableDomain(AppConfig.domains, (success, allowUpdate, message) => this.firstAttempt(success, allowUpdate, message))
    })
  }

  initData() {
    TCDefaultDomain = AppConfig.domains[0]
    TCDefaultTendDomain = AppConfig.trendChartDomains
  }

  uploadLog() {
    AsyncStorage.getItem('uploadLog').then((response) => {
      if (response != null) {
        create.create().uploadLog('INFO', response).then((response) => {
          if (response.ok) {
            AsyncStorage.removeItem('uploadLog')
          }
        })
      }
    })
  }

  backHandle = () => {
    const currentScreen = getCurrentScreen(this.props.router)
    if (currentScreen === 'Login') {
      return true
    }
    if (currentScreen !== 'Home') {
      this.props.dispatch(NavigationActions.back())
      return true
    }
    return false
  }

  codePushDownloadDidProgress(progress) {
    if (downloadTime === 0) {
      downloadTime = Moment().format('X')
    }
    this.setState({
      progress
    })
  }

  hotFix(hotfixDeploymentKey) {
    console.log('======', hotfixDeploymentKey)
    this.setState({
      syncMessage: '检测更新中...',
      updateStatus: 0
    })

    CodePush.checkForUpdate(hotfixDeploymentKey).then((update) => {
      console.log('checking update', update)
      if (update !== null) {
        NativeModules.JXCodepush.resetLoadModleForJS(true)
        this.setState({
          syncMessage: '获取到更新，正在疯狂加载...',
        })
        this.storeLog({
          hotfixDomainAccess: true
        })

        if (alreadyInCodePush) return
        alreadyInCodePush = true

        update.download(this.codePushDownloadDidProgress.bind(this)).then((localPackage) => {
          if (localPackage) {
            this.setState({
              syncMessage: '下载完成,开始安装',
              progress: false,
            })

            downloadTime = Moment().format('X') - downloadTime
            this.storeLog({
              downloadStatus: true,
              downloadTime: downloadTime
            })
            localPackage.install(CodePush.InstallMode.IMMEDIATE).then(() => {
              this.storeLog({
                updateStatus: true
              })
              console.log('=====installed')
              CodePush.notifyAppReady().then(() => {
                // this.setUpdateFinished()
              })
            }).catch((ms) => {
              this.storeLog({
                updateStatus: false,
                message: '安装失败,请重试...'
              })
              this.updateFail('安装失败,请重试...')
            })
          } else {
            this.storeLog({
              downloadStatus: false,
              message: '下载失败,请重试...'
            })
            this.updateFail('下载失败,请重试...')
          }
        }).catch((ms) => {
          this.storeLog({
            downloadStatus: false,
            message: '下载失败,请重试...'
          })
          this.updateFail('下载失败,请重试...')
        })
      } else {
        console.log('update checking value')
        this.skipUpdate()
      }
    }).then(() => {
      setTimeout(() => {
        this.setState({
          syncMessage: '正在加速更新中...',
        })
      }, 3000)
    }).then(() => { // here stop
      this.timer = setTimeout(() => {
        if (!this.state.progress && !this.state.updateFinished) {
          this.storeLog({
            downloadStatus: false,
            message: '下载失败,请重试...'
          })
          this.updateFail('下载失败,请重试...')
        }
      }, 10 * 1000)
    }).catch((ms, error) => {
      this.storeLog({
        hotfixDomainAccess: false,
        message: '更新失败,请重试...'
      })
      this.updateFail('更新失败,请重试...')
    })
  }

  updateFail(message) {
    this.setState({
      syncMessage: message,
      updateStatus: -1
    })

    this.uploadLog()
  }

  getLoadingView() {
    let progressView
    if (this.state.progress) {
      progressView = (
        <Text>
            正在下载({parseFloat(this.state.progress.receivedBytes / (1024 * 1024)).toFixed(2)}M/{parseFloat(this.state.progress.totalBytes / (1024 * 1024)).toFixed(2)}M) { (parseFloat(this.state.progress.receivedBytes / this.state.progress.totalBytes).toFixed(2) * 100).toFixed(1)}%</Text>
      )
    } else {
      return (<View  style={{ flex: 1}}>
        <TopNavigationBar title={AppConfig.appName} needBackButton={false}/>
        <View style={{justifyContent:'center',alignItems:'center',flex:1}}>
          <Text style={{fontSize: 16}}>{this.state.syncMessage}</Text>
        </View>
      </View>)
    }
    return (
      <View style={{ flex: 1}}>
          <TopNavigationBar title={AppConfig.appName} needBackButton={false}/>
          <View style={{justifyContent:'center',alignItems:'center',flex:1}}>
            {progressView}
            <Progress.Bar progress={(this.state.progress.receivedBytes / this.state.progress.totalBytes).toFixed(2)} width={200}/>
          </View>
        </View>
    )
  }

  updateFailView() {
    return (
      <View style={{ flex: 1}}>
          <TopNavigationBar title={AppConfig.appName} needBackButton={false}/>
          <View style={{justifyContent: 'center', alignItems: 'center', flex: 1}}>
            <Text style={{
              fontWeight: 'bold',
              fontSize: 16
            }}> {this.state.syncMessage}</Text>
            <View>
              <TouchableOpacity
                  onPress={() => {
                    retryTimes++
                    if (retryTimes >= 3) {
                      this.finalFailRoute() //delevoper 记得注释掉
                      this.skipUpdate()
                    } else {
                      this.initDomain()
                    }
                  }}
                  style={{
                    backgroundColor: '#3056b2',
                    justifyContent: 'center',
                    flexDirection: 'row',
                    height: 40,
                    alignItems: 'center',
                    borderRadius: 4,
                    padding: 10,
                    width: width * 0.6,
                    marginTop: 20
                  }}
              >
                <Text style={{
                  color: 'white',
                  fontWeight: 'bold',
                  fontSize: 18
                }}>
                  重试一下
                </Text>
              </TouchableOpacity>
            </View>
          </View>
        </View>
    )
  }

  render() {
    const {
      dispatch,
      router
    } = this.props
    const navigation = addNavigationHelpers({
      dispatch,
      state: router
    })
    if (!this.state.updateFinished && this.state.updateStatus == 0) {
      return this.getLoadingView()
    } else if (this.state.updateStatus == -1) {
      return this.updateFailView()
    } else
      return <AppNavigator navigation={navigation}/>
  }
}

export function routerReducer(state, action = {}) {
  return AppNavigator.router.getStateForAction(action, state)
}

function mapStateToProps({
  router
}) {
  return {
    router
  }
}

export default connect(mapStateToProps)(Router)