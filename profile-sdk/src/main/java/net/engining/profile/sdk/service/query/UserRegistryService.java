package net.engining.profile.sdk.service.query;


import com.querydsl.core.Tuple;
import com.querydsl.core.types.dsl.BooleanExpression;
import com.querydsl.jpa.impl.JPAQuery;
import com.querydsl.jpa.impl.JPAQueryFactory;
import net.engining.pg.parameter.ParameterFacility;
import net.engining.pg.support.db.querydsl.FetchResponse;
import net.engining.pg.support.db.querydsl.JPAFetchResponseBuilder;
import net.engining.profile.entity.model.QProfileBranch;
import net.engining.profile.entity.model.QProfileSecoperLog;
import net.engining.profile.entity.model.QProfileUser;
import net.engining.profile.enums.OperationType;
import net.engining.profile.sdk.service.bean.param.UserRegistryDetailsReq;
import net.engining.profile.sdk.service.bean.param.UserRegistryDetailsRes;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import java.util.ArrayList;
import java.util.List;

/**
 * 用户登记薄
 *
 * @author heqingxi
 * @date2019/7/28
 */
@Service
public class UserRegistryService {

    @PersistenceContext
    private EntityManager em;

    private Logger logger = LoggerFactory.getLogger(getClass());

    @Autowired
    private ParameterFacility parameterFacility;

    /**
     * 用于为导出用户登记薄数据
     *
     * @param uReDetailsReq
     * @return
     */
    public FetchResponse<UserRegistryDetailsRes> excelData(UserRegistryDetailsReq uReDetailsReq) {
        FetchResponse<UserRegistryDetailsRes> userResponse = getSecopeDetails(uReDetailsReq);
        return userResponse;
    }

    /**
     * 用户登记薄查询
     *
     * @param uRegDetailsReq 用户登记薄查询详情接口
     * @return 详情信息
     */

    public FetchResponse<UserRegistryDetailsRes> getSecopeDetails(UserRegistryDetailsReq uRegDetailsReq) {
        String puid = uRegDetailsReq.getPuId();
        String affiliation = uRegDetailsReq.getAffiliation();
        String userName = uRegDetailsReq.getUserName();
        String userId = uRegDetailsReq.getUserId();
        String department = uRegDetailsReq.getDepartment();

        //用户信息表
        QProfileUser qProfileUser = QProfileUser.profileUser;
        //用户登记薄表
        QProfileSecoperLog profileSecoperLog = QProfileSecoperLog.profileSecoperLog;
        //部门表
        QProfileBranch profileBranch = QProfileBranch.profileBranch;
        BooleanExpression w1 = null;
        BooleanExpression w2 = null;
        BooleanExpression w3 = null;
        BooleanExpression w4 = null;
        BooleanExpression w5 = null;
        BooleanExpression w6 = null;
        BooleanExpression w7 = null;
        if (StringUtils.isNotBlank(affiliation)) {
            w1 = qProfileUser.orgId.eq(affiliation);
        }
        if (StringUtils.isNotBlank(department)) {
            w5 = profileBranch.branchName.like("%" + department + "%");
        }
        //用户id查询
        if (StringUtils.isNotBlank(userId)) {
            w2 = qProfileUser.userId.eq(userId);
        }
        //用户名模糊查询
        if (StringUtils.isNotBlank(userName)) {
            w3 = qProfileUser.name.like("%" + userName + "%");
        }
        //如果俩个都不为空，俩者必须匹配
        if (StringUtils.isNotBlank(userName) && StringUtils.isNotBlank(userId)) {
            w3 = qProfileUser.name.eq(userName);
        }
        w4 = qProfileUser.userId.eq(profileSecoperLog.beoperatedId);
        w6 = profileBranch.orgId.eq(qProfileUser.branchId);
        w7 =profileSecoperLog.operType.notIn(OperationType.LG);
        // 查询用户登记薄 记录被操作员信息以及操作员变更信息详情信息细节
        JPAQuery<Tuple> query = new JPAQueryFactory(em)
                .select(qProfileUser.userId, qProfileUser.name, qProfileUser.orgId, qProfileUser.branchId,
                        qProfileUser.status, qProfileUser.email, profileSecoperLog.operType, profileSecoperLog.puId, profileSecoperLog.operTime, profileSecoperLog.beoperatedId,profileBranch.branchName)
                .from(qProfileUser, profileSecoperLog, profileBranch).where(w1, w2, w3, w4, w5,w6,w7).orderBy(profileSecoperLog.operTime.desc()).orderBy(qProfileUser.name.desc());
        FetchResponse<Tuple> build = new JPAFetchResponseBuilder<Tuple>().range(uRegDetailsReq.getRange()).build(query);
        List<UserRegistryDetailsRes> userRegistryList = new ArrayList<>();
        for (Tuple tuple : build.getData()) {
            UserRegistryDetailsRes searchBean = new UserRegistryDetailsRes();
            searchBean.setOrgId(tuple.get(qProfileUser.orgId));
            searchBean.setEmail(tuple.get(qProfileUser.email));
            String operUser = new JPAQueryFactory(em).select(qProfileUser.userId).from(qProfileUser)
                    .where(qProfileUser.puId.eq(tuple.get(profileSecoperLog.puId))).fetchFirst();
            searchBean.setOperRecUserId(operUser);
            searchBean.setOperType(tuple.get(profileSecoperLog.operType).toString());
            searchBean.setOperTime(tuple.get(profileSecoperLog.operTime).toString());
            searchBean.setStatus(tuple.get(qProfileUser.status).toString());
            searchBean.setName(tuple.get(qProfileUser.name));
            searchBean.setUserId(tuple.get(qProfileUser.userId));
            searchBean.setBranchId(tuple.get(profileBranch.branchName));
            userRegistryList.add(searchBean);
        }
        FetchResponse<UserRegistryDetailsRes> fetches = new FetchResponse<>();
        fetches.setData(userRegistryList);
        fetches.setRowCount(build.getRowCount());
        fetches.setStart(uRegDetailsReq.getRange().getStart());
        return fetches;
    }
}




