public with sharing class CampaignMembershipUtils {

	private static final String ALL_NUMERICS = '1234567890';

	public Boolean isCustomerEligibleForCampaign(Contact customer, Campaign campaign) {
		if (campaign.CampaignThresholds__r.isEmpty() || String.isBlank(campaign.Equation__c)) {
			return false;
		}

		String equation = campaign.Equation__c;

		for (CampaignThreshold__c threshold : campaign.CampaignThresholds__r) {
			final CampaignThresholdUtils.ResolverData resolverData = new CampaignThresholdUtils.ResolverData();
			resolverData.customer = customer;
			resolverData.campaign = campaign;
			resolverData.threshold = threshold;

			if (((CampaignThresholdUtils.IResolver) Type.forName(
					CampaignThresholdUtils.class.getName() + '.' + 
					threshold.RecordType.DeveloperName + 
					CampaignThresholdUtils.RESOLVER_CLASS_SUFFIX
				).newInstance()).isThresholdMet(resolverData)
			) {
				equation = equation.replace(
					String.valueOf(threshold.EquationPlace__c), ReversePolishNotation.TRUE_SHORT
				);
			} else {
				equation = equation.replace(
					String.valueOf(threshold.EquationPlace__c), ReversePolishNotation.FALSE_SHORT
				);
			}
		}

		if (equation.containsAny(ALL_NUMERICS)) {
			throw new StringException(String.format(Label.EquationResolveError, new List<String>{equation}));
		}

		return ReversePolishNotation.evaluateString(equation);
	}

}