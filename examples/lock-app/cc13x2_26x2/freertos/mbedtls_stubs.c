/*
 *
 *    Copyright (c) Texas Instruments Incorporated
 *    All rights reserved.
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *        http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */

/**
 *    @file
 *          Stub implementations of mbedtls functions
 *
 * XXX: Seth, figure out mbedtls
 *
 */

#include <stdlib.h>

int mbedtls_hardclock_poll( void *data,
                    unsigned char *output, size_t len, size_t *olen )
{
    // XXX: Seth, definitely not doing what it should
    return( 0 );
}

int mbedtls_platform_entropy_poll( void *data, unsigned char *output, size_t len,
                           size_t *olen )
{
    // XXX: Seth, definitely not doing what it should
    return( 0 );
}

