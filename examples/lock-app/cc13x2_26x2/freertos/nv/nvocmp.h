/******************************************************************************

 @file  nvocmp.h

 @brief NV definitions for CC26xx devices - On-Chip Multi-Page Flash Memory

 Group: CMCU, LPC
 $Target Device: DEVICES $

 ******************************************************************************
 $License: BSD3 2019 $
 ******************************************************************************
 $Release Name: PACKAGE NAME $
 $Release Date: PACKAGE RELEASE DATE $
 *****************************************************************************/
#ifndef NVOCMP_H
#define NVOCMP_H

#ifdef __cplusplus
extern "C"
{
#endif

#ifndef NV_LINUX
#include <ti/drivers/NVS.h>
#endif

#include "nvintf.h"

#warning "=== DO NOT RELEASE === Code should be pushed back to common components"
#warning "=== DO NOT RELEASE === Do Not push to Github"

//*****************************************************************************
// Constants and definitions
//*****************************************************************************

// NV driver item ID definitions
#define NVOCMP_NVID_DIAG {NVINTF_SYSID_NVDRVR, 1, 0}

//*****************************************************************************
// Typedefs
//*****************************************************************************

// NV driver diagnostic data
typedef struct
{
    uint32_t compacts;  // Number of page compactions
    uint16_t resets;    // Number of driver resets (power on)
    uint16_t available; // Number of available bytes after last compaction
    uint16_t active;    // Number of active items after last compaction
    uint16_t deleted;   // Number of items not transferred during compaction
    uint16_t badCRC;    // Number of bad CRCs encountered
}
NVOCMP_diag_t;

// Low Voltage Check Callback function, voltage is measured voltage value
typedef void (*lowVoltCbFptr)(uint32_t voltage);
//*****************************************************************************
// Functions
//*****************************************************************************

/**
 * @fn      NVOCMP_loadApiPtrs
 *
 * @brief   Global function to return function pointers for NV driver API that
 *          are supported by this module, NULL for functions not supported.
 *
 * @param   pfn - pointer to caller's structure of NV function pointers
 *
 * @return  none
 */
extern void NVOCMP_loadApiPtrs(NVINTF_nvFuncts_t *pfn);

/**
 * @fn      NVOCMP_loadApiPtrsExt
 *
 * @brief   Global function to return function pointers for NV driver API that
 *          are supported by this module, NULL for functions not supported.
 *          This function also loads the 'extended' API function pointers.
 *
 * @param   pfn - pointer to caller's structure of NV function pointers
 *
 * @return  none
 */
extern void NVOCMP_loadApiPtrsExt(NVINTF_nvFuncts_t *pfn);

/**
 * @fn      NVOCMP_loadApiPtrsMin
 *
 * @brief   Global function to return function pointers for NV driver API that
 *          are supported by this module, NULL for functions not supported.
 *          This function loads the minimum necessary API functions.
 *          This should allow smaller code size.
 *
 * @param   pfn - pointer to caller's structure of NV function pointers
 *
 * @return  none
 */
extern void NVOCMP_loadApiPtrsMin(NVINTF_nvFuncts_t *pfn);

/**
 * @fn      NVOCMP_setCheckVoltage
 *
 * @brief   Global function to allow user to provide a voltage check function
 *          for the driver to use. If a pointer is provided, the driver will
 *          call the provided function before flash erases and writes. The
 *          provided function should return true when the battery voltage is
 *          sufficient and vice versa. The user can withdraw their function
 *          by passing a NULL pointer to this function.
 *
 * @param   funcPtr - pointer to a function which returns a bool.
 *
 * @return  none
 */
extern void NVOCMP_setCheckVoltage(void *funcPtr);

/**
 * @fn      NVOCMP_setLowVoltageCb
 *
 * @brief   Global function to allow user to provide a low voltage callback function
 *          for the driver to use. If a pointer is provided, the driver will
 *          call the provided function when low voltage detected.
 *
 * @param   funcPtr - pointer to a function.
 *
 * @return  none
 */
extern void NVOCMP_setLowVoltageCb(lowVoltCbFptr funcPtr);

// Exception function can be defined to handle NV corruption issues
// If none provided, NV module attempts to proceed ignoring problem
#if !defined (NVOCMP_EXCEPTION)
#define NVOCMP_EXCEPTION(pg, err)
#endif

#ifdef NVDEBUG
// NVS Handle for debug
extern NVS_Handle nvsHandle;
#endif

#ifdef __cplusplus
}
#endif

#endif /* NVOCMP_H */

