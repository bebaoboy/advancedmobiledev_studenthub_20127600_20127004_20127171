class Endpoints {
  Endpoints._();

  // base url
  static const String baseUrl = "http://34.16.137.128";

  // receiveTimeout
  static const int receiveTimeout = 15000;

  // connectTimeout
  static const int connectionTimeout = 30000;

  // unused
  static const String getPosts = "/api/posts";

  // project

  // all project in dashboard
  static const String getProjects = "$baseUrl/api/project";
  static const String getCurrentCompanyProjects =
      "$baseUrl/project/company/{companyId}";
  static const String addNewProject = "$baseUrl/api/project";
  static const String deleteProject = "$baseUrl/api/project/{projectId}";
  static const String updateProject = "$baseUrl/api/project/{projectId}";
  static const String getUserFavoriteProjects =
      "$baseUrl/api/favoriteProject/{studentId}";

  // use to remove from favorite list
// "{
//   "projectId": 2,
//   "disableFlag": 1
// }"
  static const String updateUserFavoriteProject =
      "$baseUrl/api/favoriteProject/{studentId}";

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

  // user endpoints
  static const String resetPassword = "$baseUrl/api/user/{id}"; // done
  static const String getUsers = "$baseUrl/api/user"; // done
  static const String changePassword =
      "$baseUrl/api/user/changePassword"; // done
  static const String forgetPassword =
      "$baseUrl/api/user/forgotPassword"; // done

  // profile
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

  static const String getTechStack = "$baseUrl/api/techstack/getAllTechStack";
  static const String getSkillset = "$baseUrl/api/skillset/getAllSkillSet";
  static const String addTechStack = "$baseUrl/api/techstack/createTechStack";
  static const String addSkillset = "$baseUrl/api/skillset/createSkillSet";
}
