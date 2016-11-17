/***************************************************************************
**
** Copyright (C) 2014 Marko Koschak (marko.koschak@tisno.de)
** All rights reserved.
**
** This file is part of ownKeepass.
**
** ownKeepass is free software: you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 2 of the License, or
** (at your option) any later version.
**
** ownKeepass is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with ownKeepass. If not, see <http://www.gnu.org/licenses/>.
**
***************************************************************************/

#include "PasswordGeneratorAdapter.h"
#include "crypto/Crypto.h"

PasswordGeneratorAdapter::PasswordGeneratorAdapter(QObject *parent):
    QObject(parent),
    m_lowerLetter(true),
    m_upperLetters(true),
    m_numbers(true),
    m_specialCharacters(false),
    m_excludeLookAlike(true),
    m_charFromEveryGroup(true),
    m_passwordLength(12)
{
    Crypto::init();
}

QString PasswordGeneratorAdapter::generatePassword()
{
    PasswordGenerator::setLength(m_passwordLength);
    PasswordGenerator::setCharClasses(charClasses());
    PasswordGenerator::setFlags(generatorFlags());

    if (PasswordGenerator::isValid()) {
        QString password = PasswordGenerator::generatePassword();
        return password;
    } else {
        return "";
    }

}

void PasswordGeneratorAdapter::setLowerLetters(const bool value)
{
    m_lowerLetter = value;
}

void PasswordGeneratorAdapter::setUpperLetters(const bool value)
{
    m_upperLetters = value;
}

void PasswordGeneratorAdapter::setNumbers(const bool value)
{
    m_numbers = value;
}

void PasswordGeneratorAdapter::setSpecialCharacters(const bool value)
{
    m_specialCharacters = value;
}

void PasswordGeneratorAdapter::setExcludeLookAlike(const bool value)
{
    m_excludeLookAlike = value;
}

void PasswordGeneratorAdapter::setCharFromEveryGroup(const bool value)
{
    m_charFromEveryGroup = value;
}

void PasswordGeneratorAdapter::setPasswordLength(const int value)
{
    m_passwordLength = value;
}

PasswordGenerator::CharClasses PasswordGeneratorAdapter::charClasses()
{
    PasswordGenerator::CharClasses classes;

    if (m_lowerLetter) {
        classes |= PasswordGenerator::LowerLetters;
    }

    if (m_upperLetters) {
        classes |= PasswordGenerator::UpperLetters;
    }

    if (m_numbers) {
        classes |= PasswordGenerator::Numbers;
    }

    if (m_specialCharacters) {
        classes |= PasswordGenerator::SpecialCharacters;
    }

    return classes;
}
PasswordGenerator::GeneratorFlags PasswordGeneratorAdapter::generatorFlags()
{
    PasswordGenerator::GeneratorFlags flags;

    if (m_excludeLookAlike) {
        flags |= PasswordGenerator::ExcludeLookAlike;
    }

    if (m_charFromEveryGroup) {
        flags |= PasswordGenerator::CharFromEveryGroup;
    }

    return flags;
}
