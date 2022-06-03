---
author: joannaleecy
title: XblMultiplayerSessionDeleteCustomPropertyJson
description: Deletes a session custom property.
kindex: XblMultiplayerSessionDeleteCustomPropertyJson
ms.author: migreen
ms.topic: reference
security: public
edited: 00/00/0000
applies-to: pc-gdk
quality: good
---

# XblMultiplayerSessionDeleteCustomPropertyJson  

Deletes a session custom property.  

## Syntax  
  
```cpp
HRESULT XblMultiplayerSessionDeleteCustomPropertyJson(  
         XblMultiplayerSessionHandle handle,  
         const char* name  
)  
```  
  
### Parameters  
  
*handle* &nbsp;&nbsp;\_In\_  
Type: [XblMultiplayerSessionHandle](../handles/xblmultiplayersessionhandle.md)  
  
Handle to the multiplayer session.  
  
*name* &nbsp;&nbsp;\_In\_z\_  
Type: char*  
  
The name of the property to delete.  
  
  
### Return value  
Type: HRESULT
  
HRESULT return code for this API operation.
  
## Requirements  
  
**Header:** multiplayer_c.h
  
**Library:** Microsoft.Xbox.Services.141.GSDK.C.lib
  
## See also  
[multiplayer_c](../multiplayer_c_members.md)  
  
  