#warning "unimplemented file"

#include <openthread/platform/settings.h>

/* settings API */
void otPlatSettingsInit(otInstance *aInstance)
{
}

void otPlatSettingsDeinit(otInstance *aInstance)
{
}

otError otPlatSettingsBeginChange(otInstance *aInstance)
{
    return(OT_ERROR_NONE);
}

otError otPlatSettingsCommitChange(otInstance *aInstance)
{
    return(OT_ERROR_NONE);
}

otError otPlatSettingsAbandonChange(otInstance *aInstance)
{
    return(OT_ERROR_NONE);
}

otError otPlatSettingsGet(otInstance *aInstance, uint16_t aKey, int aIndex,
                          uint8_t *aValue, uint16_t *aValueLength)
{
    otError error  = OT_ERROR_NOT_FOUND;
    return(error);
}

otError otPlatSettingsSet(otInstance *aInstance, uint16_t aKey,
                          const uint8_t *aValue, uint16_t aValueLength)
{
    otError error  = OT_ERROR_NOT_FOUND;
    return(error);
}

otError otPlatSettingsAdd(otInstance *aInstance, uint16_t aKey,
                          const uint8_t *aValue, uint16_t aValueLength)
{
    otError error            = OT_ERROR_FAILED;
    return(error);
}

otError otPlatSettingsDelete(otInstance *aInstance, uint16_t aKey, int aIndex)
{
    otError error            = OT_ERROR_NONE;
    return(error);
}

void otPlatSettingsWipe(otInstance *aInstance)
{
}
