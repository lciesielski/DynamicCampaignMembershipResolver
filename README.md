# Salesforce Dynamic Campaign Resolver

[![Salesforce CI (Ant migration tool)](https://github.com/lciesielski/DynamicCampaignMembershipResolver/actions/workflows/ant.yml/badge.svg)](https://github.com/lciesielski/DynamicCampaignMembershipResolver/actions/workflows/ant.yml)

## Use Case

Marketing Cloud connected to Salesforce instance was populating CampaignMember records based on specific conditions.
However, the requirements stated that campaign membership should be more dynamic and flexible. 
It could be something like a weekend flash sale, specific product "last-items" discount or extended employee bonus during an intensive recruitment process.

### The Problem

Given the dynamic and potentially complex campaigns, the biggest problem we faced was that we did not know when to recalculate CampaignMember records.
It could be from something as simple as current month equals customer birth month to something as complex as 
happy hour from 3pm-5pm for specific services, but only if you bought something in the past month or you are an employee and it is valid for specific cities. As you can see from the second campaign example, we simply could not pinpoint the exact moment to recalculate CampaignMembers and scheduling a batch every one or five minutes seemed not to be an optimal approach.

### The Solution

We have started thinking about solutions that will dynamically on demand check whether a given customer(s) is eligible for the selected campaign(s).
No matter the time of the day or night, the solution had to respond to the current state of campaign assignment.
With that being said, we tackled the first part of having complex boolean logic in the campaign. 
This brings us to implementing `eval` in Salesforce.
While we read a lot of discussion about `eval` being dangerous, difficult to debug and overall not considered as best practice, we felt that it fits nicely with our campaign equation logic.

We wanted to do this properly and implement a simple yet powerful `eval` for strings that contain boolean logic.
That is how we learned about Reverse Polish Notation and implemented `ReversePolishNotation`. 
To learn more please take a look at the **Recognition** section of this readme.

Next we had to consider different campaign entry thresholds like, mentioned above. 
Time threshold, date threshold, city threshold etc. We needed this to be easily extendible, yet to have logic separated in different contexts and easy to read.
That is how we created `IResolver` interface and applied separate inner classes to each threshold.
We have followed the approach of convention over configuration where each resolver class is named by convention : 
_{thresholdRecordTypeDeveloperName}{CampaignThresholdUtils.RESOLVER_CLASS_SUFFIX}_

This gave us the following :
* Easily extendable logic with the possibility of adding different fields for different threshold record types or adding new thresholds all together.
* Separate logic held in different classes for each threshold allows for easy modification of existing thresholds without worrying about breaking everything else.
* Utilizing Reverse Polish Notation to quickly change campaign equations within existing thresholds, without the need for code deployment.

## Information About Implementation

This was built and is validated using Salesforce Developer Org. Also, profiles, objects and layouts were retrieved from Salesforce Developer Org, so it might be the case where not all of this package may be useful\needed.

### Prerequisites

Salesforce developer sandbox or production. 
Tool for deployment (_ant_ or _sfdx_)

### Installation

Run deployment target with your deployment tool with files specified in package.xml
If you currently utilize any of objects from the package you will have to merge changes from this package into your working solution.

### Usage

You will have to create a campaign with thresholds. Three sample thresholds included in this package are :
_Birthday_ which will be met if the customer's birth month is the current month
_Employee_ which will be met if the customer is also an employee
_Weekend_ which will be met if the current day is weekend day

Basically, what you want to do is gather your customers and campaigns that you want to check against.
Required fields to be selected (with logic included in this package) are `Birthdate` and `IsEmployee__c` from `Contact` object and
`Equation__c` from `Campaign` object.
Also, within campaign SOQL you will have to include subquery for thresholds with fields included being `EquationPlace__c` and `RecordType.DeveloperName`

In the end below is sample code that you can run.

```
final Boolean result = new CampaignMembershipUtils().isCustomerEligibleForCampaign([
            SELECT Birthdate, IsEmployee__c 
            FROM Contact LIMIT 1
        ], [
        SELECT Equation__c, 
            (SELECT EquationPlace__c, RecordType.DeveloperName FROM CampaignThresholds__r) 
        FROM Campaign
        WHERE Equation__c != null
        LIMIT 1
    ]);
```

## Recognition

[This](https://salesforce.stackexchange.com/questions/113300/boolean-evaluation-in-apex) post on Stack Overflow regarding Reverse Polish Notation was of huge help. `ReversePolishNotation` class is heavily based on **kurunve** post, so thank you for that.