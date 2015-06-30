public class ARController 
{
    public ConfidentialFolder__c folder {get;set;}
    ApexPages.StandardController std;
    IMC_Marketing_Campaign__c campaign;
    public String campaignID {get;set;}
    String confidentialStr = '';
    public Boolean confidential {get;set;} {confidential = true;}
    public ARObject__c aro {get;set;}
    ID folderID;
    
	public ARController(ApexPages.StandardController stdc)
    {
        std = stdc;
        campaignID = ApexPages.currentPage().getParameters().get('cam');
        confidentialStr = ApexPages.currentPage().getParameters().get('con');
        if ((confidentialStr != null) && (confidentialStr.equals('1')))
            confidential = true;
        
        if ((campaignID == null) || (campaignID.length() < 1))
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'INVALID PAGE URL: NO CAMPAIGN ID PARAMETER'));
        }
        
        folder = new ConfidentialFolder__c(); // instantiate this as a placeholder, but it's only used for Confidential Folders
        folder.Initiative__c = campaignID;
        campaign = [SELECT Id, FolderID__c FROM IMC_Marketing_Campaign__c WHERE Id =: campaignID];
        aro = new ARObject__c();
    }   

    public PageReference saveFolder()
    {
        PageReference pr;
		Database.SaveResult sr;
		Database.Error[] errors;
        
        try
        {
            if ((folder.Name == null) || (folder.Name.length() < 1))
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Folder Name is Required'));
                return null;               
            }

            if (confidential)
            {
                sr = Database.insert(folder);
                if (!sr.isSuccess())
                {
                    errors = sr.getErrors();
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errors[0].getMessage()));
                    return null; 
                }      
                
                folderID = sr.getId();                
                folder = [SELECT Id, Name FROM ConfidentialFolder__c WHERE Id =: folderID];
                
                aro.Confidential_Folder__c = folderID;
                sr = Database.insert(aro);                
                if (!sr.isSuccess())
                {
                    errors = sr.getErrors();
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errors[0].getMessage()));
                    return null; 
                } 
                
                pr = new ApexPages.StandardController(folder).view();
            }
            else if (campaign != null)
            {
                pr = new ApexPages.StandardController(campaign).view();
            }

        }
        catch (Exception e)
        {
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()));
            return null;            
        }
        
        pr.setRedirect(true);
        return pr;
    }
}