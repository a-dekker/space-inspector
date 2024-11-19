/*
 * This file is part of harbour-space-inspector.
 * SPDX-FileCopyrightText: 2024 Mirian Margiani
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef INCL_CONSTANTS_H
#define INCL_CONSTANTS_H

#include "io/enumcontainer.h"

CREATE_ENUM(ViewMode, Box = 0, List = 1)

DECLARE_ENUM_REGISTRATION_FUNCTION(SpaceInspector)

#ifdef __HACK_TO_FORCE_MOC
Q_OBJECT
#endif

#endif  // INCL_CONSTANTS_H
