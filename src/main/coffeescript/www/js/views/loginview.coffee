define [
  'views/baseview'
  'util'
  'text!templates/signin.tmpl'
  'text!templates/signup.tmpl'
  'db_util'
],(
  BaseView
  Util
  signinTemplate
  signupTemplate
  DB
) ->

  class LoginView extends BaseView
    el: $('#loginview_content')

    events:
      'click #signin':'onSigninSelected'
      'click #signup':'onSignupSelected'

      'click #signinview':'onSigninViewSelected'
      'click #signupview':'onSignupViewSelected'

    initialize: (options) =>
      @template = _.template(signinTemplate)

      #@projectCollection = options.projectCollection
      

    onShow: ->
      super
      $("#loginpage_headertitle").text Util.i18n("app_name")

    onSigninSelected: (e) ->
      e.stopImmediatePropagation()
      e.preventDefault()
      
      Util.showPageLoading true

      DB.signin @$el.find("#email").val(), @$el.find("#password").val(), (ok) =>
        Util.showPageLoading false        
        if ok
          require ['routers'], (Router) ->
            Router.navigate("#map", {trigger: true})
        else 
          Util.showErrorPrompt Util.i18n('signin_failure')

    onSignupSelected: (e) ->
      e.stopImmediatePropagation()
      e.preventDefault()

      DB.signup @$el.find("#email").val(), @$el.find("#password").val(), (ok) =>
        if ok
          Util.showPrompt Util.i18n('ok')
        else 
          Util.showErrorPrompt Util.i18n('signup_failure')

    onSigninViewSelected: (e) ->
      e.stopImmediatePropagation()
      e.preventDefault()
      @template = _.template(signinTemplate)
      @render()

    onSignupViewSelected: (e) ->
      e.stopImmediatePropagation()
      e.preventDefault()
      @template = _.template(signupTemplate)
      @render()

    render: ->
      @$el.slideUp "slow", =>
        @$el.html @template
          'Util': Util
        @$el.enhanceWithin()
        @$el.slideDown "slow"
      @


  LoginView
