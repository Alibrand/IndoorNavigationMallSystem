import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rachidmallsystem/model/FireResponse.dart';
import 'package:rachidmallsystem/model/FireUser.dart';
import 'package:rachidmallsystem/model/MarketPlace.dart';

class FireBaseHelper {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  FireRespone response = FireRespone(status: "OK", message: "", data: null);

  //***********User Authentication Functions*********** */

  Future<FireRespone> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final user = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      FireUser fireUser = FireUser(id: user.user!.uid, email: email);
      response.status = "OK";
      response.message = "Welcome Admin";
      response.data = fireUser;
      return response;
    } catch (e) {
      response.status = "Error";
      response.message = e.toString();
      return response;
    }
  }

  Future<FireRespone> updatePassword(
      String email, String oldPass, String newPass) async {
    try {
      final currentUser = _auth.currentUser;
      final credentials =
          EmailAuthProvider.credential(email: email, password: oldPass);

      await currentUser!
          .reauthenticateWithCredential(credentials)
          .then((value) async {
        await currentUser.updatePassword(newPass).then((value) {
          response.status = "OK";
          response.message = "Password has been changed succesfully";
        }).catchError((error) {
          response.status = "Error";
          response.message = error.toString();
        });
      });
      return response;
    } catch (e) {
      response.status = "Error";
      response.message = e.toString();
      return response;
    }
  }

  void signOut() {
    _auth.signOut();
  }

  //*********Marketplace functions ***********//
  Future<FireRespone> getFloorMarketPlaces(int floor) async {
    try {
      final places = await _firestore
          .collection('marketplaces')
          .where("floor", isEqualTo: floor)
          .get();
      List<MarketPlace> floorMarketPlaces = <MarketPlace>[];
      if (places.docs.isEmpty) {
        response.status = "OK";
        response.message = "No Place was found in floor " + floor.toString();
      } else {
        response.status = "OK";
        for (var place in places.docs) {
          var placeData = place.data();
          placeData.addAll({"doc_id": place.id});
          MarketPlace mPlace = MarketPlace.fromJson(placeData);
          floorMarketPlaces.add(mPlace);
        }
      }
      response.data = floorMarketPlaces;

      return response;
    } catch (e) {
      response.status = "Error";
      response.message = e.toString();
      return response;
    }
  }

  Future<FireRespone> searchMarketPlaces(String searchKey) async {
    try {
      final places = await _firestore
          .collection('marketplaces')
          .where("keywords", arrayContains: searchKey)
          .limit(5)
          .get();

      List<MarketPlace> floorMarketPlaces = <MarketPlace>[];
      if (places.docs.isEmpty) {
        response.status = "OK";
        response.message = "No Search results ";
      } else {
        response.status = "OK";

        for (var place in places.docs) {
          var placeData = place.data();
          placeData.addAll({"doc_id": place.id});
          MarketPlace mPlace = MarketPlace.fromJson(placeData);
          floorMarketPlaces.add(mPlace);
        }
      }
      response.data = floorMarketPlaces;

      return response;
    } catch (e) {
      response.status = "Error";
      response.message = e.toString();
      return response;
    }
  }

  Future<FireRespone> createNewMarkPlace(MarketPlace newplace) async {
    try {
      await _firestore.collection('marketplaces').add(newplace.toJson());
      response.message = "New place Saved Successfully";
      return response;
    } catch (e) {
      response.status = "Error";
      response.message = e.toString();
      return response;
    }
  }

  Future<FireRespone> deleteMarkPlace(MarketPlace place) async {
    try {
      await _firestore.collection('marketplaces').doc(place.doc_id).delete();
      response.message = "Place has been Deleted Successfully";
      return response;
    } catch (e) {
      response.status = "Error";
      response.message = e.toString();
      return response;
    }
  }

  Future<FireRespone> updateMarkPlace(MarketPlace place) async {
    try {
      await _firestore
          .collection('marketplaces')
          .doc(place.doc_id)
          .update(place.toJson());
      response.message = "Place Updated Successfully";
      return response;
    } catch (e) {
      response.status = "Error";
      response.message = e.toString();
      return response;
    }
  }
}
