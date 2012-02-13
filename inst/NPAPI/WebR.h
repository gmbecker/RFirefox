//https://raw.github.com/jskorpan/BoilerplateNp/master/npcommon/ScriptableObject.h
#ifndef WEBR_H
#define WEBR_H 1
#include <npapi.h>
//#include <npupp.h>
#include <string>
#include <npruntime.h>
#include <R.h>
#include <Rdefines.h>
class WebREngine : public NPObject
{
protected:
    // Class member functions that do the real work
    void Deallocate();
    void Invalidate();
    bool HasMethod(NPIdentifier name);
    bool Invoke(NPIdentifier name, const NPVariant *args, uint32_t argCount, NPVariant *result);
    bool InvokeDefault(const NPVariant *args, uint32_t argCount, NPVariant *result);
    bool HasProperty(NPIdentifier name);
    bool GetProperty(NPIdentifier name, NPVariant *result);
    bool SetProperty(NPIdentifier name, const NPVariant *value);
    bool RemoveProperty(NPIdentifier name);
    bool Enumerate(NPIdentifier **identifier, uint32_t *count);
    bool Construct(const NPVariant *args, uint32_t argCount, NPVariant *result);

public:
		WebREngine (NPP instance);
		void Detatch (void);

		// This is the method used to create the NPObject
    // This method should not be called explicitly
    // Instead, use NPN_CreateObject
    static NPObject* Allocate(NPP npp, NPClass *aClass);

    /////////////////////////////
    // Static NPObject methods //
    /////////////////////////////
    static void _Deallocate(NPObject *npobj);
    static void _Invalidate(NPObject *npobj);
    static bool _HasMethod(NPObject *npobj, NPIdentifier name);
    static bool _Invoke(NPObject *npobj, NPIdentifier name, const NPVariant *args, uint32_t argCount, NPVariant *result);
    static bool _InvokeDefault(NPObject *npobj, const NPVariant *args, uint32_t argCount, NPVariant *result);
    static bool _HasProperty(NPObject * npobj, NPIdentifier name);
    static bool _GetProperty(NPObject *npobj, NPIdentifier name, NPVariant *result);
    static bool _SetProperty(NPObject *npobj, NPIdentifier name, const NPVariant *value);
    static bool _RemoveProperty(NPObject *npobj, NPIdentifier name);
    static bool _Enumerate(NPObject *npobj, NPIdentifier **identifier, uint32_t *count);
    static bool _Construct(NPObject *npobj, const NPVariant *args, uint32_t argCount, NPVariant *result);
 
    static NPClass _npclass;
 
protected:
    NPP m_Instance;
	
private:

	NPIdentifier m_getVersion_id;
	//Probably don't need this because of m_Instance above!!
	NPP instance;
};


bool ConvertRToNP(SEXP val, NPP inst, NPVariant *ret);
bool RVectorToNP(SEXP vec, NPP inst, NPVariant *ret);
SEXP ConvertNPToR(NPVariant var, NPP inst) ;
SEXP NPArrayToR(NPVariant arr, int len, int simplify, NPP inst);
SEXP makeNPVarRef(NPVariant *ref);

#endif

