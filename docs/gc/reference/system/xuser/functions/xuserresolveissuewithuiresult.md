---
author: M-Stahl
title: XUserResolveIssueWithUiResult
description: Retrieves the result of a call to XUserResolveIssueWithUiAsync.
kindex: XUserResolveIssueWithUiResult
ms.author: v-sahain
ms.topic: reference
edited: 00/00/0000
quality: good
security: public
applies-to: pc-gdk
---

# XUserResolveIssueWithUiResult  

Retrieves the result of a call to [XUserResolveIssueWithUiAsync](xuserresolveissuewithuiasync.md).  

## Syntax  
  
```cpp
HRESULT XUserResolveIssueWithUiResult(  
         XAsyncBlock* async  
)  
```  
  
### Parameters  
  
*async* &nbsp;&nbsp;\_Inout\_  
Type: [XAsyncBlock*](../../xasync/structs/xasyncblock.md)  

The AsyncBlock we pass to [XUserResolveIssueWithUiAsync](xuserresolveissuewithuiasync.md).

### Return value

Type: HRESULT
  
Returns S_OK if successful; otherwise, returns an error code. For a list of error codes, see [Error Codes](../../../errorcodes.md).  

| Return Code           | Description             |
|-----------------------|-------------------------|
| S_OK                  | The operation succeeded |
| E_ABORT               | The user canceled the operation |
  
## Remarks

If an XUsers API returns an E_GAMEUSER_RESOLVE_USER_ISSUE_REQUIRED error, the user must interact with the system user interface (UI) to resolve the issue.
Call [XUserResolveIssueWithUiAsync](xuserresolveissuewithuiasync.md) to show the appropriate system UI.

To display a system User Interface for solving token issues with a unicode URL, call [XUserResolveIssueWithUiUtf16Async](xuserresolveissuewithuiutf16async.md).

To retrieve the result of a call to [XUserResolveIssueWithUiUtf16Async](xuserresolveissuewithuiutf16async.md), call [XUserResolveIssueWithUiUtf16Result](xuserresolveissuewithuiutf16result.md).

The following example demonstrates how to display the system UI to resolve token issues with a URL.

```cpp
HRESULT ResolveUserIssueComplete(XAsyncBlock* ab)
{
    if (SUCCEEDED_LOG(XUserResolveIssueWithUiResult(ab)))
    {
        appLog.AddLog("Successfully Resolved User Issue\n");
    }

    return S_OK;
}

HRESULT ResolveUserIssueUtf16Complete(XAsyncBlock* ab)
{
    if (SUCCEEDED_LOG(XUserResolveIssueWithUiUtf16Result(ab)))
    {
        appLog.AddLog("Successfully Resolved User Issue\n");
    }

    return S_OK;
}

HRESULT ResolveUserIssueWithUiAsync(
    XTaskQueueHandle queue,
    const char* narrowUrl = nullptr,
    const wchar_t* wideUrl = nullptr,
    bool useUtf16 = false)
{
    auto resolveAsyncBlock = std::make_unique<XAsyncBlock>();
    ZeroMemory(resolveAsyncBlock.get(), sizeof(*resolveAsyncBlock));
    resolveAsyncBlock->queue = queue;
    resolveAsyncBlock->context = this;

    if (useUtf16)
    {
        resolveAsyncBlock->callback = [](XAsyncBlock* ab)
        {
            auto asyncBlock = std::unique_ptr<XAsyncBlock>(ab);
            LOG_IF_FAILED(static_cast<User*>(ab->context)->ResolveUserIssueUtf16Complete(ab));
        };

        if (SUCCEEDED_LOG(XUserResolveIssueWithUiUtf16Async(
            _handle.get(),
            wideUrl,
            resolveAsyncBlock.get())))
        {
            // The call succeeded, so release the std::unique_ptr ownership of XAsyncBlock* since the callback will take over ownership.
            // If the call fails, the std::unique_ptr will keep ownership and delete the XAsyncBlock*
            resolveAsyncBlock.release();
        }
    }
    else
    {
        resolveAsyncBlock->callback = [](XAsyncBlock* ab)
        {
            auto asyncBlock = std::unique_ptr<XAsyncBlock>(ab);
            LOG_IF_FAILED(static_cast<User*>(ab->context)->ResolveUserIssueComplete(ab));
        };

        if (SUCCEEDED_LOG(XUserResolveIssueWithUiAsync(
            _handle.get(),
            narrowUrl,
            resolveAsyncBlock.get())))
        {
            // The call succeeded, so release the std::unique_ptr ownership of XAsyncBlock* since the callback will take over ownership.
            // If the call fails, the std::unique_ptr will keep ownership and delete the XAsyncBlock*
            resolveAsyncBlock.release();
        }
    }

    return S_OK;
}
```

  
## Requirements  
  
**Header:** XUser.h
  
**Library:** xgameruntime.lib  
  
**Supported platforms:** Windows, Xbox One family consoles and Xbox Series consoles  
  
## See also

[XUser](../xuser_members.md)
  
[XUserResolveIssueWithUiAsync](xuserresolveissuewithuiasync.md)

[XUserResolveIssueWithUiUtf16Async](xuserresolveissuewithuiutf16async.md)

[XUserResolveIssueWithUiUtf16Result](xuserresolveissuewithuiutf16result.md)