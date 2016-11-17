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


#ifndef PASSWORDGENERATORADAPTER_H
#define PASSWORDGENERATORADAPTER_H

#include <QObject>

#include "core/PasswordGenerator.h"


class PasswordGeneratorAdapter : public QObject, private PasswordGenerator
{
    Q_OBJECT
    Q_DISABLE_COPY(PasswordGeneratorAdapter)

public:
    Q_PROPERTY(bool lowerLetters READ lowerLetters WRITE setLowerLetters)
    Q_PROPERTY(bool upperLetters READ upperLetters WRITE setUpperLetters)
    Q_PROPERTY(bool numbers READ numbers WRITE setNumbers)
    Q_PROPERTY(bool specialCharacters READ specialCharacters WRITE setSpecialCharacters)
    Q_PROPERTY(bool excludeLookAlike READ excludeLookAlike WRITE setExcludeLookAlike)
    Q_PROPERTY(bool charFromEveryGroup READ charFromEveryGroup WRITE setCharFromEveryGroup)
    Q_PROPERTY(int length READ passwordLength WRITE setPasswordLength)

    Q_INVOKABLE QString generatePassword();

public:
    PasswordGeneratorAdapter(QObject *parent = 0);

    bool lowerLetters() const { return m_lowerLetter; }
    void setLowerLetters(const bool value);
    bool upperLetters() const { return m_upperLetters; }
    void setUpperLetters(const bool value);
    bool numbers() const { return m_numbers; }
    void setNumbers(const bool value);
    bool specialCharacters() const { return m_specialCharacters; }
    void setSpecialCharacters(const bool value);
    bool excludeLookAlike() const { return m_excludeLookAlike; }
    void setExcludeLookAlike(const bool value);
    bool charFromEveryGroup() const { return m_charFromEveryGroup; }
    void setCharFromEveryGroup(const bool value);
    int passwordLength() const { return m_passwordLength; }
    void setPasswordLength(const int value);

private:
    PasswordGenerator::CharClasses charClasses();
    PasswordGenerator::GeneratorFlags generatorFlags();

private:
    bool m_lowerLetter;
    bool m_upperLetters;
    bool m_numbers;
    bool m_specialCharacters;
    bool m_excludeLookAlike;
    bool m_charFromEveryGroup;
    int m_passwordLength;
};

#endif // PASSWORDGENERATORADAPTER_H

