
callJavaScript = function( name, ..., object = getGlobalJSObject(), multipleArgs = FALSE, keepResult = TRUE, convertRet = "default", convertArgs = NULL)
  {
    args = list(...)

    if(missing(convertArgs))
      print("convertArgs is missing!!!")
   
    #check whether we are in Firefox or NPAPI-browser
    if(exists("ScriptCon"))
      #Need to update the RFirefox API if this is going to stay in
      #call_JS_Method(ScriptCon, object, name, args, multipleArgs, addRoot = keepResult)
      TRUE
    else
      {
        #NPAPI call code goes here!
        NP_Invoke(obj = object, name = name, convertRet = convertRet, convertArgs = convertArgs, keepResult = keepResult, argList = args)
      }
  }

evalJavaScript = function(script, scope = getGlobalJSObject(), keepResult = TRUE, convertRet="default")
  {
    if(length(script)>1)
      script = paste(script, collapse = "\n")
    if(exists("ScriptCon"))
      {
        toret = jsVal()
        JS_EvaluateScript(ScriptCon, scope, script, nchar(script), "evalingJS", 1, toret)
        if(keepResult)
          {
            JS_AddRoot(ScriptCon, toret)
            toret
          } else {
            TRUE
          }
      } else {
        #NPAPI eval code goes here
        #function(object = getGlobalJSObject(), name, multipleArgs = FALSE, keepResult = TRUE, convertRet = FALSE, convertArgs, ...)
        callJavaScript(object = scope, name = "eval", script, convertRet = convertRet, keepResult = keepResult)
      }
  }

'jsProperty<-' = function(object, name, value, convertValue = "default")
  {
    print(paste("in jsProperty<-, class of object is", class(object)))
    if(length(name) > 1)
      {
        for(i in seq(along=name))
          jsProperty(object, name[i], convertValue = convertValue[i]) <- value[i]
        return(object)
      }
    
    if(exists("ScriptCon"))
      set_JS_Property(ScriptCon, object, name, value)
    else
      {
        #NPAPI property set code goes here
        NP_SetProperty(obj = object, name = name, value = value, convertValue = convertValue)
      }
    print(paste("leaving jsProperty<-, class of object is", class(object)))
    #object
    return(object)
  }

jsProperty = function(object, name, convertRet = "default")
  {
    if(length(name) > 1)
      return(mapply(function(nm, conv) jsProperty(object, nm, conv), name, convertRet))
    if(exists("ScriptCon"))
      get_JS_Property(ScriptCon, object, name)
    else
      {
        #NPAPI property get code here
        NP_GetProperty(obj = object, name = name, convertRet = convertRet)
      }
  }

getGlobalJSObject = function()
  {
    if(exists("ScriptCon"))
      JS_GlobalObject(ScriptCon) #Need to figure out if this needs addRoot = TRUE or not!!!
    else
      {
        #NPAPI code goes here
        res = NP_GetGlobal()
        res
      }
  }

getPageElement = function(id, convertRet = "default")
  {
    if(length(id) > 1)
      return(mapply(getPageElement, id, convertRet))
    #When JS object is implemented
    ret = JS[["document"]]$getElementById(id, convertRet)
    if(is(ret, "JSValueRef"))
      ret = as(ret, "JSDOMRef")
    ret
    
  }

addTextNode = function(parent = NULL, content = "hello world!")
  {
    doc = JS[["document"]]
    if(is.null(parent))
      parent = doc
    tnode = doc$createTextNode(content)
    parent$appendChild(tnode)
    NULL
  }

addPageElement = function(parent = NULL, type="div", id=NULL, attributes = list())
  {
    if(is.character(parent))
      parent = getPageElement(parent)
    doc = JS[["document"]]
    if(is.null(parent))
      {
        parent = doc[["body"]]
      }
    el = doc$createElement(type )
 
    if(!is.null(id))
      el$setAttribute("id", id)
    if(length(attributes))
      mapply(function(nm, at) el$setAttribute(nm, at), nm = names(attributes), at = attributes)

 
    parent$appendChild(el)
}    


removePageElement = function(id, object=NULL)
  {

    if(is.null(object))
      object = getPageElement(id)

    #Code to remove element.
  }

#addEventListener = function(target, event, rfun)
#  {
#    if(length(event) > 1)
#      return(mapply(function(e, f) addEventListener(target, e, f), event, rfun))
#    target$addEventListener(event, rfun)
#    TRUE
#  }

setGeneric("addEventListener", function(target, event, rfun, ...) standardGeneric("addEventListener"))

setMethod("addEventListener", c(target = "JSRaphaelRef"),
          function(target, event, rfun, ...)
          {
            if(length(event) > 1)
              return(sapply(event, function(e) addEventListener(target, e, rfun, ...)))
            nd = target[["node"]]
            print("JSRaphaelRef method")
            print(nd)
            addEventListener(nd, event, rfun, ...)
          })
setMethod("addEventListener", c(target = "RaphPaperRef"),
          function(target, event, rfun, ...)
          {
            if(length(event) > 1)
              return(sapply(event, function(e) addEventListener(target, e, rfun, ...)))
            nd = target[["canvas"]]
            addEventListener(nd, event, rfun, ...)
          })

setMethod("addEventListener", c(target="list"),
          function(target, event, rfun, ...)
          {
            mapply(function(t, e) addEventListener(t, e, rfun, ...),
                   t = target, e=event)
            
          })

setMethod("addEventListener", c(target="JSValueRef"),
          function(target, event, rfun, ...)
          {
            if(length(event) > 1)
              return(mapply(function(e, f) addEventListener(target, e, f,...), event, rfun))
            args = list(...)
            if("event" %in% names(formals(rfun)))
              hfun = function(evt)
                {
                  do.call(rfun, c(event=evt, args))
                }
            else
              hfun = function(evt)
                {
                  do.call(rfun, args)
                }
            
         #   target$addEventListener(event, rfun)
            print(target)
#            target$addEventListener(event, hfun)
            JS$makeHandler(target, event, hfun)
            NULL
          })
removeEventListener = function(target, event)
  {
    TRUE
  }

raiseDOMEvent = function(target, type)
  {


    TRUE
  }

toR = function(object)
  {

    TRUE
  }


setMethod("names", "JSValueRef", function(x)
          {
            TRUE
          })

setMethod("length", "JSValueRef", function(x)
          {
            x[["length"]]
          })

            
setMethod("[[", c("JSValueRef", "character", "missing"), function(x, i, ...)
          {
            jsProperty(x, i, ...)
          })

setMethod("[[", c("JSValueRef", "numeric", "missing"), function(x, i, ...)
          {
            i = as.character(as.integer(i))
            jsProperty(x, i, ...)
          })


setMethod("[[<-", c("JSValueRef", "character", "missing"), function(x, i, ..., value)
          {
            jsProperty(x, i, ...) <- value
            x
          })

setMethod("[[<-", c("JSValueRef", "numeric", "missing"), function(x, i, ..., value)
          {
            i = as.character(as.integer(i))
            ret = jsProperty(x, i, ...) <- value
            x
          })

#setGeneric("$", function(x, name, ...) standardGeneric("$"))
#setMethod("$", "JSValueRef",
setMethod("$", "JSValueRef",
          function(x, name)
          {

            #fun = function( ...,  keepResult = TRUE, returnRef = FALSE, convertArgs)
            fun = function( ...,  keepResult = TRUE, convertRet = "default", convertArgs = NULL)
              {
              
                args = list(...)
                if(length(args) > 1)
                  multipleArgs = TRUE
                else
                  multipleArgs = FALSE

                callJavaScript(object = x,name =  name, ... , multipleArgs = multipleArgs, keepResult = keepResult, convertRet = convertRet, convertArgs = convertArgs)
              }
#            attr(fun, "NPRef") <- x[[name]]
            fun
          }
          )

setGeneric("newJSObject", function(obj, ...) standardGeneric("newJSObject"))

setMethod("newJSObject", "character",
          function(obj, ...)
          {
            obj = evalJavaScript(obj)
            newJSObject(obj, ...)
          })

setMethod("newJSObject", "JSValueRef",
          function(obj, ...)
          {
            paramlist = c(obj, list(...))
            fun = switch(length(paramlist),
                   JS$create0,
                   JS$create1,
                   JS$create2,
                   JS$create3,
                   JS$create4,
                   default=stop("Creation of JS objects whose constructors require more than 4 arguments via newJSObject is not currently supported."))
            do.call(fun, paramlist)
          })
            

getEventLocation = function(evt, user.coords = TRUE)
    {
        print("In getEventLocation")
        loc = as.numeric(JS$offsets(evt, convertRet = "copy"))
        print(loc)
        if(user.coords)
            loc = c(grconvertX(loc[1], from="device", to="user"),
                grconvertY(loc[2], from="device", to="user")
                )
        print(loc)
        names(loc) = c("x", "y")
        print(loc)
        loc
    }
                    
        
