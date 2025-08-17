#!/bin/bash

# Set the GitHub token
export GITHUB_TOKEN=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

# Configure Git to use the token for HTTPS authentication
git config --global credential.helper store
echo "https://BoozeLee444:$GITHUB_TOKEN@github.com" > ~/.git-credentials

# Set Git username and email
git config --global user.email "kiliaanv2@gmail.com"
git config --global user.name "BoozeLee444"

# Verify authentication
echo "Verifying GitHub authentication..."
gh auth status

# List all repositories
echo "Fetching list of repositories..."
repos=$(gh repo list --limit 1000 | awk '{print $1}')

# Define the new license text
NEW_LICENSE="# Bakerstreet Restricted Project License

**Copyright © 2025 Bakerstreet Project Company. All rights reserved.**

This license governs the use of the software, code, smart contracts, documentation, and associated materials (collectively, the \"Project\") in this GitHub repository, developed by Bakerstreet Project Company (the \"Licensor\"). This license complies with applicable international and Belgian domestic laws, including but not limited to the Berne Convention for the Protection of Literary and Artistic Works, the World Intellectual Property Organization (WIPO) Copyright Treaty, and the Belgian Code of Economic Law (Book XI, Intellectual Property).

## 1. Definitions
- **Project**: All source code, scripts (e.g., Python, JavaScript), smart contracts (e.g., Solidity files), documentation, and related materials in this repository.
- **Licensor**: Bakerstreet Project Company, a Belgian entity, the sole owner and copyright holder of the Project.
- **Licensee**: Any individual or entity accessing or using the Project.
- **Use**: Viewing or running the Project’s code for non-commercial, personal evaluation or educational purposes on a local machine, without deploying smart contracts or integrating with external systems.

## 2. Grant of License
Subject to the terms and conditions of this License, the Licensor grants the Licensee a non-exclusive, non-transferable, revocable, limited license to:
- View and run the Project’s code (e.g., Python scripts, AI/ML models) solely for personal, non-commercial evaluation or educational purposes on a local machine, in accordance with Article XI.165 of the Belgian Code of Economic Law (protection of software).
- Inspect the Project’s smart contract code (e.g., Solidity files), if applicable, solely via the GitHub repository for educational purposes, without compilation or deployment.

## 3. Restrictions
The Licensee is expressly prohibited from:
- **Modifying**: Altering, adapting, or creating derivative works of the Project, as protected under Article 2 of the Berne Convention and Article XI.190 of the Belgian Code of Economic Law (copyright protection).
- **Distributing**: Copying, sharing, redistributing, or making the Project available to others, including via repositories, websites, or blockchain networks, per Article 8 of the WIPO Copyright Treaty.
- **Commercial Use**: Using the Project for any commercial purpose, including selling, licensing, deploying smart contracts, or incorporating into commercial products or services, in violation of Article XI.194 of the Belgian Code of Economic Law.
- **Deploying Smart Contracts**: Compiling, deploying, or interacting with the Project’s smart contract(s) on any blockchain (mainnet, testnet, or private network).
- **Reverse Engineering**: Decompiling, disassembling, or attempting to derive source code, smart contract logic, or algorithms beyond what is publicly provided, as prohibited under Article XI.167 of the Belgian Code of Economic Law.
- **Sublicensing**: Granting or transferring any rights under this License to third parties.
- **Removing Notices**: Removing or altering any copyright, license, or attribution notices, in violation of Article 7 of the Berne Convention.

## 4. Security and Intellectual Property
- **Ownership**: The Licensor retains all rights, title, and interest in the Project, including all intellectual property rights (copyright, patents, trade secrets) under the Berne Convention, WIPO Copyright Treaty, and Belgian Code of Economic Law (Book XI, Title 5).
- **Security Measures**: The Licensee must not bypass, disable, or circumvent any security features, cryptographic protections, or restrictions in the Project, as such actions may violate Article XI.297 of the Belgian Code of Economic Law (protection against circumvention of technological measures).
- **Confidentiality**: Proprietary algorithms, smart contract logic, or data handling mechanisms are confidential and must not be disclosed or used outside this License’s scope, in accordance with Belgian trade secret protections (Article XI.332).
- **Audit Rights**: The Licensor reserves the right to audit or monitor usage to ensure compliance with this License and applicable laws.

## 5. Termination
- This License is effective until terminated. The Licensor may terminate it at any time by updating the repository or notifying the Licensee.
- Upon termination, the Licensee must cease all use and delete local copies of the Project, as required under Article XI.190 of the Belgian Code of Economic Law.
- Any violation automatically terminates the Licensee’s rights.

## 6. Disclaimer of Warranty
The Project is provided \"as is\" without warranty of any kind, express or implied, including merchantability, fitness for a particular purpose, or non-infringement, as permitted under Article 7 of the WIPO Copyright Treaty and Belgian law.

## 7. Limitation of Liability
To the fullest extent permitted by law, the Licensor shall not be liable for any direct, indirect, incidental, special, consequential, or punitive damages arising from the use or inability to use the Project, in accordance with Article XI.190 of the Belgian Code of Economic Law.

## 8. Governing Law and Jurisdiction
This License is governed by the laws of Belgium, specifically the Belgian Code of Economic Law, and international treaties including the Berne Convention and WIPO Copyright Treaty. Any disputes shall be resolved exclusively in the courts of Hasselt, Belgium.

## 9. Contact
For inquiries, contact Bakerstreet Project Company via the GitHub repository (https://github.com/BoozeLee).

**By accessing or using the Project, you agree to be bound by this License and applicable international and Belgian laws. If you do not agree, you must not access or use the Project.**
"

# Function to update a single repository
update_repo() {
    local repo=$1
    echo "Processing repository: $repo"
    
    # Create a temporary directory
    temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # Clone the repository using gh to ensure proper authentication
    echo "Cloning repository..."
    gh repo clone "$repo" .
    
    # Remove existing license files
    echo "Removing existing license files..."
    rm -f LICENSE LICENSE.md LICENSE.txt
    
    # Write the new license
    echo "Writing new license..."
    echo "$NEW_LICENSE" > LICENSE
    
    # Check if there are changes to commit
    if [[ -n "$(git status --porcelain)" ]]; then
        echo "Committing changes..."
        git add LICENSE
        git config --global user.email "action@github.com"
        git config --global user.name "GitHub Action"
        git commit -m "Update license to Bakerstreet Restricted Project License"
        
        # Push changes
        echo "Pushing changes..."
        git push
    else
        echo "No changes to commit."
    fi
    
    # Clean up
    cd ..
    rm -rf "$temp_dir"
}

# Process each repository
for repo in $repos; do
    update_repo "$repo"
done

echo "License update process completed."