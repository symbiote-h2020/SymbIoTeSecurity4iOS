//
//  SecurityConstants.swift
//  SecuritySSP


import Foundation

/**
For consistentcy this class is based on java code from eu.h2020.symbiote.security  https://github.com/symbiote-h2020/SymbIoTeSecurity/blob/develop/src/main/java/eu/h2020/symbiote/security/commons/SecurityConstants.java
*/
public class SecurityConstants{
    
    // Security GLOBAL
    public static let CURVE_NAME = "secp256r1";
    public static let KEY_PAIR_GEN_ALGORITHM = "ECDSA";
    public static let SIGNATURE_ALGORITHM = "SHA256withECDSA";
    
    // AAM GLOBAL
    public static let CORE_AAM_FRIENDLY_NAME = "SymbIoTe Core AAM";
    public static let CORE_AAM_INSTANCE_ID = "SymbIoTe_Core_AAM";
    
    // component certificates resolver constants
    public static let AAM_COMPONENT_NAME = "aam";
    
    // AAM REST paths
    public static let AAM_GET_AVAILABLE_AAMS = "/get_available_aams";
    public static let AAM_GET_AAMS_INTERNALLY = "/get_internally_aams";
    public static let AAM_GET_COMPONENT_CERTIFICATE = "/get_component_certificate";
    public static let AAM_GET_FOREIGN_TOKEN = "/get_foreign_token";
    public static let AAM_GET_GUEST_TOKEN = "/get_guest_token";
    public static let AAM_GET_HOME_TOKEN = "/get_home_token";
    public static let AAM_GET_USER_DETAILS = "/get_user_details";
    public static let AAM_MANAGE_PLATFORMS = "/manage_platforms";
    public static let AAM_MANAGE_USERS = "/manage_users";
    public static let AAM_REVOKE_CREDENTIALS = "/revoke_credentials";
    public static let AAM_SIGN_CERTIFICATE_REQUEST = "/sign_certificate_request";
    public static let AAM_VALIDATE_CREDENTIALS = "/validate_credentials";
    public static let AAM_VALIDATE_FOREIGN_TOKEN_ORIGIN_CREDENTIALS = "/validate_foreign_token_origin_credentials";
    
    
    // tokens
    public static let TOKEN_HEADER_NAME = "x-auth-token";
    public static let  JWT_PARTS_COUNT = 3; //Header, body and signature
    public static let CLAIM_NAME_TOKEN_TYPE = "ttyp";
    public static let SYMBIOTE_ATTRIBUTES_PREFIX = "SYMBIOTE_";
    public static let FEDERATION_CLAIM_KEY_PREFIX = "federation_";
    public static let GUEST_NAME = "guest";
    
    // certificates
    public static let CLIENT_CERTIFICATE_HEADER_NAME = "x-auth-client-cert";
    public static let AAM_CERTIFICATE_HEADER_NAME = "x-auth-aam-cert";
    public static let FOREIGN_TOKEN_ISSUING_AAM_CERTIFICATE = "x-auth-iss-cert";
    
    // Security Request Headers
    public static let SECURITY_CREDENTIALS_TIMESTAMP_HEADER = "x-auth-timestamp";
    public static let SECURITY_CREDENTIALS_SIZE_HEADER = "x-auth-size";
    public static let SECURITY_CREDENTIALS_HEADER_PREFIX = "x-auth-";
    public static let SECURITY_RESPONSE_HEADER = "x-auth-response";
    
    //Access Policy JSON fields
    //Single Token
    public static let ACCESS_POLICY_JSON_FIELD_TYPE = "policyType";
    public static let ACCESS_POLICY_JSON_FIELD_CLAIMS = "requiredClaims";
    
    //Composite AP
    public static let ACCESS_POLICY_JSON_FIELD_OPERATOR = "relationOperator";
    public static let ACCESS_POLICY_JSON_FIELD_SINGLE_TOKEN_AP = "singleTokenAccessPolicySpecifiers";
    public static let ACCESS_POLICY_JSON_FIELD_COMPOSITE_AP = "compositeAccessPolicySpecifiers";
    
    public static let ERROR_DESC_UNSUPPORTED_ACCESS_POLICY_TYPE = "Access policy type not suppoted!";
}
