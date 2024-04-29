class Endpoints {

  Endpoints._();

  // base url
  // static const String baseUrl = "http://34.16.137.128";
  static const String baseUrl = "https://api.studenthub.dev";

  // receiveTimeout
  static const int receiveTimeout = 30000;

  // connectTimeout
  static const int connectionTimeout = 30000;

  // unused
  static const String getPosts = "/api/posts";

  //////////////////////////////////// chat /////////////////////////////////

  /// để hiện lên tab message?
  static const String getMessageByProject = "$baseUrl/api/message/{projectId}";

  /// all message of a chat
  static const String getMessageByProjectAndUser =
      "$baseUrl/api/message/{projectId}/user/{userId}"; // done
  /// all message of yourself
  static const String getAllChat = "$baseUrl/api/message"; // done

  // static const String getAllMessagePaging = "$baseUrl/api/message/get/page";

  //////////////////////////////////// project /////////////////////////////////
  // all project in dashboard
  static const String getProjects = "$baseUrl/api/project"; // done
  /*
    "result": [
    {
      "id": 151,
      "createdAt": "2024-04-10T04:26:40.237Z",
      "updatedAt": "2024-04-10T04:26:40.237Z",
      "deletedAt": null,
      "companyId": "11",
      "projectScopeFlag": 1,
      "title": "Test Project 2",
      "description": "description of the project",
      "numberOfStudents": 1,
      "typeFlag": 0,
      "proposals": [],
      "countProposals": 0,
      "countMessages": 0,
      "countHired": 0
    },
    ] */
  static const String getCurrentCompanyProjects =
      "$baseUrl/api/project/company/{companyId}"; // done
  /*
      {
  "result": {
    "companyId": "11",
    "projectScopeFlag": 3,
    "title": "Test Project 3",
    "numberOfStudents": 1,
    "description": "description of the project",
    "typeFlag": 0,
    "updatedAt": "2024-04-10T04:27:03.283Z",
    "deletedAt": null,
    "id": 152,
    "createdAt": "2024-04-10T04:27:03.283Z"
  }
} */
  static const String getStudentProposalProjects =
      "$baseUrl/api/proposal/project/{studentId}"; // done
  static const String getCandidatesOfProject =
      "$baseUrl/api/proposal/getByProjectId/{projectId}"; // done
  // offset (number), limit(number), q(string),
  // order(e.g. order=createdAt:DESC), statusFlag(string)

  static const String postProposal = "$baseUrl/api/proposal"; // done
  static const String updateProposal = "$baseUrl/api/proposal/{id}"; // done

  static const String addNewProject = "$baseUrl/api/project"; // done
  static const String deleteProject =
      "$baseUrl/api/project/{projectId}"; // done
  static const String updateProject =
      "$baseUrl/api/project/{projectId}"; // done
  static const String getUserFavoriteProjects = // done
      "$baseUrl/api/favoriteProject/{studentId}";

  // use to remove from favorite list
// "{
//   "projectId": 2,
//   "disableFlag": 1
// }"
  static const String updateUserFavoriteProject =
      "$baseUrl/api/favoriteProject/{studentId}"; // done

  //auth endpoints
  static const String signUp = "$baseUrl/api/auth/sign-up"; // done
  static const String login = "$baseUrl/api/auth/sign-in"; // done
  static const String getProfile = "$baseUrl/api/auth/me"; // done
  static const String logout = "$baseUrl/api/auth/logout"; // done
  // auth endpoints
  // me
  /*
  {
  "result": {
    "id": 48,
    "fullname": "bao",
    "roles": [
      "0",
      "1",
    ],
    "student": {
      "id": 11,
      "createdAt": "2024-03-31T09:49:50.109Z",
      "updatedAt": "2024-03-31T09:49:50.109Z",
      "deletedAt": null,
      "userId": 48,
      "techStackId": 1,
      "resume": null,
      "transcript": null
    },
     "company": {
      "id": 22,
      "createdAt": "2024-03-31T11:50:11.717Z",
      "updatedAt": "2024-03-31T11:50:11.717Z",
      "deletedAt": null,
      "userId": 47,
      "companyName": "string",
      "website": "string",
      "size": 0,
      "description": "string"
    }
  }
} */

  //////////////////////////////////// user /////////////////////////////////
  static const String resetPassword = "$baseUrl/api/user/{id}"; // done
  static const String getUsers = "$baseUrl/api/user"; // done
  static const String changePassword =
      "$baseUrl/api/user/changePassword"; // done
  static const String forgetPassword =
      "$baseUrl/api/user/forgotPassword"; // done

  //////////////////////////////////// profile /////////////////////////////////
  static const String addProfileCompany =
      "$baseUrl/api/profile/company"; // done
  static const String updateProfileCompany =
      "$baseUrl/api/profile/company/{id}"; // done
  static const String getProfileCompany =
      "$baseUrl/api/profile/company/{companyId}"; // done

  /* POST student profile
      {
  "result": {
    "userId": 48,
    "techStackId": 1,
    "techStack": {
      "id": 1,
      "createdAt": "2024-03-29T14:50:35.326Z",
      "updatedAt": "2024-03-29T14:50:35.326Z",
      "deletedAt": null,
      "name": "Fullstack Engineer"
    },
    "skillSets": [
      {
        "id": 1,
        "createdAt": "2024-03-29T14:50:35.424Z",
        "updatedAt": "2024-03-29T14:50:35.424Z",
        "deletedAt": null,
        "name": "C"
      },
      {
        "id": 2,
        "createdAt": "2024-03-29T14:50:35.430Z",
        "updatedAt": "2024-03-29T14:50:35.430Z",
        "deletedAt": null,
        "name": "C++"
      }
    ],
    "updatedAt": "2024-03-31T09:49:50.109Z",
    "deletedAt": null,
    "resume": null,
    "transcript": null,
    "id": 11, // student id
    "createdAt": "2024-03-31T09:49:50.109Z"
  }
} */
  static const String addProfileStudent =
      "$baseUrl/api/profile/student"; // semi-done
  static const String updateProfileStudent =
      "$baseUrl/api/profile/student/{id}"; // semidone
  static const String getProfileStudent =
      "$baseUrl/api/profile/student/{studentId}"; // done
  static const String getProfileStudentTechStack =
      "$baseUrl/api/profile/student/{studentId}/techStack"; // done above

  static const String getLanguage =
      "$baseUrl/api/language/getByStudentId/{studentId}"; // done
  static const String updateLanguage =
      "$baseUrl/api/language/updateByStudentId/{studentId}"; // done
  static const String getEducation =
      "$baseUrl/api/education/getByStudentId/{studentId}"; // done
  static const String updateEducation =
      "$baseUrl/api/education/updateByStudentId/{studentId}"; // done
  static const String getProjectExperience =
      "$baseUrl/api/experience/getByStudentId/{studentId}"; // done
  static const String updateProjectExperience =
      "$baseUrl/api/experience/updateByStudentId/{studentId}"; // done

  static const String updateResume =
      "$baseUrl/api/profile/student/{studentId}/resume"; // done

  static const String getResume =
      "$baseUrl/api/profile/student/{studentId}/resume"; // done

  static const String updateTranscript =
      "$baseUrl/api/profile/student/{studentId}/transcript"; // semidone

  static const String getTranscript =
      "$baseUrl/api/profile/student/{studentId}/transcript"; // done

  static const String deleteResume =
      "$baseUrl/api/profile/student/{studentId}/resume"; // done

  static const String deleteTranscript =
      "$baseUrl/api/profile/student/{studentId}/transcript"; // done

  static const String getTechStack =
      "$baseUrl/api/techstack/getAllTechStack"; // done
  static const String getSkillset =
      "$baseUrl/api/skillset/getAllSkillSet"; // done
  static const String addTechStack = "$baseUrl/api/techstack/createTechStack";
  static const String addSkillset = "$baseUrl/api/skillset/createSkillSet";

  //////////////////////////////////// interview /////////////////////////////////

  static const String getInterview = "$baseUrl/api/interview/{interviewId}";

  // disable interview
  static const String updateStateInterview =
      "$baseUrl/api/interview/{interviewId}/disable";

  static const String deleteInterview = "$baseUrl/api/interview/{interviewId}";
  static const String updateInterview = "$baseUrl/api/interview/{interviewId}";
  static const String disableInterview = "$baseUrl/api/interview/{interviewId}/disable";
  static const String postInterview = "$baseUrl/api/interview";

  static const String checkAvail = "$baseUrl/api/meeting-room/check-availability";
}
